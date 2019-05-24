locals {
  cityworker_host_profile = "${data.terraform_remote_state.aws_shared.city_host_profile_name}"
  city_host_profile = "${data.terraform_remote_state.aws_shared.city_host_profile_name}"
  dmz_host_profile =  "${data.terraform_remote_state.aws_shared.dmz_host_profile_name}"
  lb_host_profile =  "${data.terraform_remote_state.aws_shared.lb_host_profile_name}"
  openvpn_conf = "${var.output_directory}/${terraform.workspace}/openvpn_server_${terraform.workspace}.conf"
  cityworker_ami_id = "${var.cityworker_version == "most_recent" ? data.aws_ami.most_recent_cityworker_ami.id : data.aws_ami.particular_cityworker_ami.id}"
  city_ami_id = "${var.city_version == "most_recent" ? data.aws_ami.most_recent_city_ami.id : data.aws_ami.particular_city_ami.id}"
  lb_ami_id = "${var.lb_version == "most_recent" ? data.aws_ami.most_recent_lb_ami.id : data.aws_ami.particular_lb_ami.id}"
  dmz_ami_id = "${var.dmz_version == "most_recent" ? data.aws_ami.most_recent_dmz_ami.id : data.aws_ami.particular_dmz_ami.id}"
  cityworker_version = "${var.cityworker_version == "most_recent" ? data.aws_ami.most_recent_cityworker_ami.tags["Version"] : data.aws_ami.particular_cityworker_ami.tags["Version"]}"
  city_version = "${var.city_version == "most_recent" ? data.aws_ami.most_recent_city_ami.tags["Version"] : data.aws_ami.particular_city_ami.tags["Version"]}"
}

data "template_file" "cityworker_cloud_init" {
  count = "${var.cityworker_hosts}"
  template = "${file("${path.module}/cloud-init/cityworker_host.yml")}"
  vars {
    hostname = "${format("cityworker%01d", count.index + 1)}-${replace(local.cityworker_version, ".", "")}${terraform.workspace != "prod" ? terraform.workspace : ""}"
    cityworker_hosts = "${var.cityworker_hosts}"
    # FIXME When HCL2 / TF 0.12 come out we should interpolate the
    # github keys into this template rather than typing them in again
  }
}

resource "aws_instance" "cityworker_host" {
  count = "${var.cityworker_hosts}"
  ami = "${local.cityworker_ami_id}"
  instance_type = "t2.micro"
  user_data = "${data.template_file.cityworker_cloud_init.*.rendered[count.index]}"
  iam_instance_profile = "${local.cityworker_host_profile}"
  subnet_id = "${aws_subnet.city_private_subnet.id}"
  monitoring = true
  vpc_security_group_ids = ["${aws_security_group.city_servers.id}"]
  associate_public_ip_address = false


  lifecycle {
    create_before_destroy = 1
  }
tags {
    District = "city"
    Usage = "app"
    Name = "${format("cityworker%01d", count.index + 1)}-${replace(local.cityworker_version, ".", "")}${terraform.workspace != "prod" ? terraform.workspace : ""}"
    Role = "host"
    Environment = "${terraform.workspace}"
  }

  depends_on = ["aws_vpc.city_vpc", "aws_instance.dmz", "aws_instance.city_host"]
}

data "template_file" "city_cloud_init" {
  count = "${var.city_hosts}"
  template = "${file("${path.module}/cloud-init/city_host.yml")}"
  vars {
    hostname = "${format("city%01d", count.index + 1)}-${replace(local.city_version, ".", "")}${terraform.workspace != "prod" ? terraform.workspace : ""}"
    city_hosts = "${var.city_hosts}"
    # FIXME When HCL2 / TF 0.12 come out we should interpolate the
    # github keys into this template rather than typing them in again
  }
}

resource "aws_instance" "city_host" {
  count = "${var.city_hosts}"
  ami = "${local.city_ami_id}"
  instance_type = "t2.micro"
  user_data = "${data.template_file.city_cloud_init.*.rendered[count.index]}"
  iam_instance_profile = "${local.city_host_profile}"
  subnet_id = "${aws_subnet.city_private_subnet.id}"
  monitoring = true
  vpc_security_group_ids = ["${aws_security_group.city_servers.id}"]
  associate_public_ip_address = false


  lifecycle {
    create_before_destroy = 1
  }

  tags {
    District = "city"
    Usage = "app"
    Name = "${format("city%01d", count.index + 1)}-${replace(local.city_version, ".", "")}${terraform.workspace != "prod" ? terraform.workspace : ""}"
    Role = "host"
    Environment = "${terraform.workspace}"
  }

  depends_on = ["aws_vpc.city_vpc", "aws_instance.dmz"]
}

data "template_file" "city_lb_cloud_init" {
  template = "${file("${path.module}/cloud-init/city_lb.yml")}"
  vars {
    hostname = "city-lb${terraform.workspace != "prod" ? terraform.workspace : ""}"
    lb_district = "city" }
}

resource "aws_instance" "city_lb" {
  ami                    = "${local.lb_ami_id}"
  instance_type          = "t2.micro"
  user_data              = "${data.template_file.city_lb_cloud_init.rendered}"
  iam_instance_profile   = "${local.lb_host_profile}"
  subnet_id              = "${aws_subnet.city_vpc_subnet.id}"
  monitoring             = true
  vpc_security_group_ids = ["${aws_security_group.city_servers.id}"]

  lifecycle {
    create_before_destroy = 1
  }

  tags {
    District = "city"
    Usage    = "app"
    Name     = "city_lb${terraform.workspace != "prod" ? terraform.workspace : ""}"
    Role     = "lb"
    Environment = "${terraform.workspace}"
  }

  depends_on = ["aws_vpc.city_vpc", "aws_instance.dmz"]

  provisioner "ansible" {
    when = "create"

    connection {
      host = "${self.public_ip}"
      user = "alan"
      type = "ssh"
    }

    ansible_ssh_settings {
      insecure_no_strict_host_key_checking = true
    }

    plays {
      playbook = {
        file_path = "${path.module}/city_lb/city_lb.yml"
        roles_path = ["${path.module}/city_lb/roles"]
      }

      hosts = ["${self.public_ip}"]
      vault_id = ["${var.output_directory}/ansible-vault-password.txt"]

      extra_vars = {
        env               = "${terraform.workspace}"
        dmz_private_ip    = "${aws_instance.dmz.private_ip}"
        cluster_size      = "${var.city_hosts}"
        vault_file        = "${var.output_directory}/ansible-vault.yml"
        output_directory  = "${var.output_directory}/${terraform.workspace}"
        github_org        = "${var.github_org}"
        dev_team          = "userland"
        aws_account_id    = "${data.aws_caller_identity.current.account_id}"
        vpc_active_subnet = "172.31.0.0"
        vpc_vpn_subnet    = "172.16.0.0"
        vpn_domain        = "${terraform.workspace == "prod" ? "hole.ly" : join(".", list(terraform.workspace, "testinghole.com"))}"
      }
    }
  }

}

data "template_file" "dmz_host_cloud_init" {
  template = "${file("${path.module}/cloud-init/dmz_host.yml")}"
  vars {
    env = "${terraform.workspace}"
    hostname = "dmz${terraform.workspace != "prod" ? terraform.workspace : ""}"
  }
}

resource "aws_instance" "dmz" {
  ami                    = "${local.dmz_ami_id}"
  instance_type          = "t2.micro"
  iam_instance_profile   = "${local.dmz_host_profile}"
  user_data              = "${data.template_file.dmz_host_cloud_init.rendered}"
  subnet_id              = "${aws_subnet.city_vpc_subnet.id}"
  monitoring             = true
  vpc_security_group_ids = ["${aws_security_group.city_servers.id}", "${aws_security_group.dmz_server.id}"]
  source_dest_check      = false

  lifecycle {
    create_before_destroy = 1
  }

  tags {
    District = "dmz"
    Usage    = "infra"
    Name     = "dmz${terraform.workspace != "prod" ? terraform.workspace : ""}"
    Role     = "vpn"
    Environment = "${terraform.workspace}"
  }

  depends_on = ["aws_vpc.city_vpc", "aws_dynamodb_table.vault-secrets"]

  provisioner "ansible" {
    when = "create"

    connection {
      host = "${self.public_ip}"
      user = "alan"
      type = "ssh"
    }

    ansible_ssh_settings {
      insecure_no_strict_host_key_checking = true
    }

    plays {
      playbook = {
        file_path = "${path.module}/bootstrap/bootstrap.yml"
        roles_path = ["${path.module}/bootstrap/roles"]
      }

      hosts = ["${self.public_ip}"]
      vault_id = ["${var.output_directory}/ansible-vault-password.txt"]

      extra_vars = {
        env               = "${terraform.workspace}"
        cluster_size      = "${var.city_hosts}"
        vault_file        = "${var.output_directory}/ansible-vault.yml"
        output_directory  = "${var.output_directory}/${terraform.workspace}"
        github_org        = "${var.github_org}"
        dev_team          = "userland"
        aws_account_id    = "${data.aws_caller_identity.current.account_id}"
        vpc_active_subnet = "172.31.0.0"
        vpc_vpn_subnet    = "172.16.0.0"
        vpn_domain        = "${terraform.workspace == "prod" ? "hole.ly" : join(".", list(terraform.workspace, "testinghole.com"))}"
        api_domain        = "${terraform.workspace == "prod" ? "holepunch.io" : join(".", list(terraform.workspace, "orbtestenv.net"))}"
      }
    }
  }
}
