data "aws_ami" "city_ami" {
  most_recent = true

  filter {
    name = "name"
    values = ["CITY AMI *"]
  }

  owners = ["578925084144"]
}

data "aws_ami" "lb_ami" {
  most_recent = true

  filter {
    name = "name"
    values = ["LB AMI *"]
  }

  owners = ["578925084144"]
}

data "aws_ami" "dmz_ami" {
  most_recent = true

  filter {
    name = "name"
    values = ["DMZ AMI *"]
  }

  owners = ["578925084144"]
}

locals {
  city_host_profile = "${data.terraform_remote_state.aws_shared.city_host_profile_name}"
  dmz_host_profile =  "${data.terraform_remote_state.aws_shared.dmz_host_profile_name}"
  lb_host_profile =  "${data.terraform_remote_state.aws_shared.lb_host_profile_name}"
  openvpn_conf = "${var.output_directory}/${terraform.workspace}/openvpn_server_${terraform.workspace}.conf"
}

data "template_file" "city_cloud_init" {
  count = "${var.city_hosts}"
  template = "${file("${path.module}/cloud-init/city_host.yml")}"
  vars {
    hostname = "${format("city%01d", count.index + 1)}-${replace(data.aws_ami.city_ami.tags["Version"], ".", "")}${terraform.workspace != "prod" ? terraform.workspace : ""}"
    city_hosts = "${var.city_hosts}"
    # FIXME When HCL2 / TF 0.12 come out we should interpolate the
    # github keys into this template rather than typing them in again
  }
}

resource "aws_instance" "city_host" {
  count = "${var.city_hosts}"
  ami = "${data.aws_ami.city_ami.id}"
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
    Name = "${format("city%01d", count.index + 1)}-${replace(data.aws_ami.city_ami.tags["Version"], ".", "")}${terraform.workspace != "prod" ? terraform.workspace : ""}"
    Role = "host"
    Environment = "${terraform.workspace}"
  }

  depends_on = ["aws_vpc.city_vpc", "aws_instance.dmz"]
}

data "template_file" "city_lb_cloud_init" {
  template = "${file("${path.module}/cloud-init/city_lb.yml")}"
  vars {
    hostname = "city-lb${terraform.workspace != "prod" ? terraform.workspace : ""}"
    lb_district = "city"
  }
}

resource "aws_instance" "city_lb" {
  ami                    = "${data.aws_ami.lb_ami.id}"
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
  ami                    = "${data.aws_ami.dmz_ami.id}"
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
      }
    }
  }
}