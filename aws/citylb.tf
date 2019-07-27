locals {
  lb_host_profile =  "${data.terraform_remote_state.aws_shared.lb_host_profile_name}"
  lb_ami_id = "${var.lb_version == "most_recent" ? data.aws_ami.most_recent_lb_ami.id : data.aws_ami.particular_lb_ami.id}"
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
    create_before_destroy = true
  }

  tags = {
    District    = "city"
    Usage       = "app"
    Name        = "city_lb${terraform.workspace != "prod" ? terraform.workspace : ""}"
    Role        = "lb"
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
    source      = "post_boot_config/vault_ssh_host_keys"
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
}
