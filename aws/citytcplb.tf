locals {
  # Note the below uses the lb profile
  tcplb_host_profile = data.terraform_remote_state.aws_shared.outputs.lb_host_profile_name
  tcplb_ami_id       = var.tcplb_version == "most_recent" ? data.aws_ami.most_recent_tcplb_ami.id : data.aws_ami.particular_tcplb_ami.id
}

data "template_file" "city_tcplb_cloud_init" {
  template = "${file("${path.module}/cloud-init/city_tcplb.yml")}"
  vars = {
    hostname = "city-tcplb${terraform.workspace != "prod" ? terraform.workspace : ""}"
    tcplb_district = "city" 
    }
}

resource "aws_instance" "city_tcplb" {
  ami                    = local.tcplb_ami_id
  instance_type          = "t2.micro"
  user_data              = data.template_file.city_tcplb_cloud_init.rendered
  iam_instance_profile   = local.tcplb_host_profile
  subnet_id              = aws_subnet.city_vpc_subnet.id
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.tcplb_servers.id]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    District = "city"
    Usage    = "app"
    Name     = "city_tcplb${terraform.workspace != "prod" ? terraform.workspace : ""}"
    Role     = "tcplb"
    Environment = terraform.workspace
  }

  depends_on = ["aws_vpc.city_vpc", "aws_instance.dmz"]

  # Overwrite the standard fabio config on the node image

  provisioner "file" {
    source      = "post_boot_config/fabio/files/fabio.conf"
    destination = "/home/alan/fabio.conf"
    connection {
      host = coalesce(self.public_ip, self.private_ip)
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
      host = coalesce(self.public_ip, self.private_ip)
      type = "ssh"
      user = "alan"
    }
  }
}