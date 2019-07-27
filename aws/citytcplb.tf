locals {
  # Note the below uses the lb profile
  tcplb_host_profile =  "${data.terraform_remote_state.aws_shared.lb_host_profile_name}"
  tcplb_ami_id = "${var.tcplb_version == "most_recent" ? data.aws_ami.most_recent_tcplb_ami.id : data.aws_ami.particular_tcplb_ami.id}"
}

data "template_file" "city_tcplb_cloud_init" {
  template = "${file("${path.module}/cloud-init/city_tcplb.yml")}"
  vars {
    hostname = "city-tcplb${terraform.workspace != "prod" ? terraform.workspace : ""}"
    tcplb_district = "city" }
}

resource "aws_instance" "city_tcplb" {
  ami                    = "${local.tcplb_ami_id}"
  instance_type          = "t2.micro"
  user_data              = "${data.template_file.city_tcplb_cloud_init.rendered}"
  iam_instance_profile   = "${local.tcplb_host_profile}"
  subnet_id              = "${aws_subnet.city_vpc_subnet.id}"
  monitoring             = true
  vpc_security_group_ids = ["${aws_security_group.tcplb_servers.id}"]

  lifecycle {
    create_before_destroy = true
  }

  tags {
    District = "city"
    Usage    = "app"
    Name     = "city_tcplb${terraform.workspace != "prod" ? terraform.workspace : ""}"
    Role     = "tcplb"
    Environment = "${terraform.workspace}"
  }

  depends_on = ["aws_vpc.city_vpc", "aws_instance.dmz"]

    # Load the vault token

  provisioner "file" {
    source      = "${var.output_directory}/${terraform.workspace}/vault_recovery"
    destination = "/home/alan/vault_recovery"
    connection {
      host = "${self.public_ip}"
      type = "ssh"
      user = "alan"
    }
  }

  # Load the ssh config script
  provisioner "file" {
    source      = "PostBootConfig/vault_ssh_host_keys"
    destination = "/home/alan/vault_ssh_host_keys"
    connection {
      host = "${self.public_ip}"
      type = "ssh"
      user = "alan"
    }
  }
  # Run the config script and remove the vault key and restart ssh

  provisioner "remote-exec" {
    when = "create"
    inline = [
      "chmod +x /home/alan/vault_ssh_host_keys",
      "sudo /home/alan/vault_ssh_host_keys",
      "rm /home/alan/vault_recovery",
      "rm /home/alan/vault_ssh_host_keys",
      "sudo systemctl restart ssh",
    ]
    connection {
      host = "${self.public_ip}"
      type = "ssh"
      user = "alan"
    }
  }

  # Overwrite the standard fabio config on the node image

  provisioner "file" {
    source      = "post_boot_config/fabio/files/fabio.conf"
    destination = "/home/alan/fabio.conf"
    connection {
      type = "ssh"
      user = "alan"
    }
  }

  # Download our special fabio binary,  Move the config and fabio in place.
  # Restart the service.

  provisioner "remote-exec" {
    inline = [
      "wget https://github.com/CypherpunkArmory/fabio/releases/download/v1.5.11-alpha/fabio",
      "sudo mv /home/alan/fabio.conf /etc/fabio.conf",
      "sudo chown fabio.fabio /etc/fabio.conf",
      "sudo chmod 644 /etc/fabio.conf",
      "sudo mv /home/alan/fabio /usr/bin/fabio",
      "sudo chown root.root /usr/bin/fabio",
      "sudo chmod +x /usr/bin/fabio",
      "sudo systemctl restart fabio.service",
      "sudo systemctl status fabio.service",
    ]
    connection {
      type = "ssh"
      user = "alan"
    }
  }
}