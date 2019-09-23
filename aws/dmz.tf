locals {
  dmz_host_profile    = data.terraform_remote_state.aws_shared.outputs.dmz_host_profile_name
  dmz_ami_id          = var.dmz_version == "most_recent" ? data.aws_ami.most_recent_dmz_ami.id : data.aws_ami.particular_dmz_ami.id
  vault_recovery_file = "${var.output_directory}/${terraform.workspace}/vault_recovery"
}

data "template_file" "dmz_host_cloud_init" {
  template = file("${path.module}/cloud-init/dmz_host.yml")
  vars = {
    env = terraform.workspace
    hostname = "dmz${terraform.workspace != "prod" ? terraform.workspace : ""}"
  }
}
# This is ugly but passes values from the terraform.tfvars and the env to a file to source
# inside our provisioner shell.  The seems complex.
data "template_file" "vault_terraform_vars" {
  template = file(
    "${path.module}/post_boot_config/provisioner/vault_terraform_vars",
  )
  vars = {
    tfworkspace     = terraform.workspace
    kms_key_id      = var.kms_key_id
    dd_api_key      = var.datadog_api_key
    docker_bot_pass = var.docker_bot_pass
    cluster_size    = var.city_hosts
    github_org      = var.github_org
    dev_team        = "userland"
    vpn_domain      = terraform.workspace == "prod" ? "hole.ly" : join(".", [terraform.workspace, "testinghole.com"])
    aws_account_id  = data.aws_caller_identity.current.account_id
  }
}

data "template_file" "openvpn_terraform_vars" {
  template = file(
    "${path.module}/post_boot_config/vault-openvpn/openvpn_terraform_vars",
  )
  vars = {
   tfworkspace         = terraform.workspace
   vpn_domain          = terraform.workspace == "prod" ? "hole.ly" : join(".", [terraform.workspace, "testinghole.com"])
   vpc_active_subnet   = "172.31.0.0"
   vpc_vpn_subnet      = "172.16.0.0"
  }
}

resource "aws_instance" "dmz" {
  ami                    = local.dmz_ami_id
  instance_type          = "t2.micro"
  iam_instance_profile   = local.dmz_host_profile
  user_data              = data.template_file.dmz_host_cloud_init.rendered
  subnet_id              = aws_subnet.city_vpc_subnet.id
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.city_servers.id, aws_security_group.dmz_server.id]
  source_dest_check      = false

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    District    = "dmz"
    Usage       = "infra"
    Name        = "dmz${terraform.workspace != "prod" ? terraform.workspace : ""}"
    Role        = "vpn"
    Environment = terraform.workspace
  }

  depends_on = [
    "aws_vpc.city_vpc",
     "aws_dynamodb_table.vault-secrets",
  ]

  # CREATE output directory if it doesn't exisit
  provisioner "local-exec" {
    command =   <<EOT
      ls  ${var.output_directory}/${terraform.workspace}>/dev/null 2>&1;
      if ! [ $? = 0 ]; then
        mkdir ${var.output_directory}/${terraform.workspace}
      fi
      ls  ${local.vault_recovery_file}>/dev/null 2>&1;
      if ! [ $? = 0 ]; then
        touch ${local.vault_recovery_file}
      fi
   EOT
  }

  provisioner "file" {
     source      = local.vault_recovery_file
     destination = "/home/alan/vault_recovery"
     connection {
       host = self.public_ip
       type = "ssh"
       user = "alan"
     }
  }

  # Copy up the template files to the instance
  provisioner "file" {
    content      = data.template_file.openvpn_terraform_vars.rendered
    destination = "/home/alan/openvpn_terraform_vars"
    connection {
      host = self.public_ip
      type = "ssh"
      user = "alan"
    }
  }
    provisioner "file" {
    content      = data.template_file.vault_terraform_vars.rendered
    destination = "/home/alan/vault_terraform_vars"
    connection {
      host = self.public_ip
      type = "ssh"
      user = "alan"
    }
  }

  # Copy the config scripts to the instance
  provisioner "file" {
    source      = "post_boot_config/provisioner"
    destination = "/home/alan/"
    connection {
      host = self.public_ip
      type = "ssh"
      user = "alan"
    }
  }
  provisioner "file" {
    source      = "post_boot_config/vault-openvpn"
    destination = "/home/alan/"
    connection {
      host = self.public_ip
      type = "ssh"
      user = "alan"
    }
  }


  # Run the config scripts

  provisioner "remote-exec" {
    when = "create"
    inline = [
      "cd /home/alan/provisioner",
      "chmod +x ./provisioner",
      "sudo ./provisioner",
      "cd /home/alan/vault-openvpn",
      "chmod +x ./vault_openvpn",
      "sudo ./vault_openvpn",
    ]
    connection {
      host = self.public_ip
      type = "ssh"
      user = "alan"
    }
  }

# COPY the recovery vault recovery key, openvpn's configs to keybase
# use local-exec and scp to export the files out.
  provisioner "local-exec" {
    command = <<EOT
    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    alan@${self.public_ip}:/home/alan/vault_recovery ${var.output_directory}/${terraform.workspace}/vault_recovery;
    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    alan@${self.public_ip}:/home/alan/openvpn_client_${terraform.workspace}.ovpn ${var.output_directory}/${terraform.workspace}/openvpn_client_${terraform.workspace}.ovpn;
    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    alan@${self.public_ip}:/home/alan/openvpn_linuxclient_${terraform.workspace}.ovpn ${var.output_directory}/${terraform.workspace}/openvpn_linuxclient_${terraform.workspace}.ovpn
   EOT
  }

# Remove our code and secrets from the instance
  provisioner "remote-exec" {
    when = "create"
    inline = [
      "rm -rf /home/alan/*",
      "sudo rm -f /root/.vault-token",
      "sudo rm -f ~/.vault-token",
    ]
    connection {
      host = self.public_ip
      type = "ssh"
      user = "alan"
    }
  }
}
