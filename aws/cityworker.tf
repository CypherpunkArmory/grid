locals {
 # Note the below uses the city host profile
 cityworker_host_profile = data.terraform_remote_state.aws_shared.outputs.city_host_profile_name
 cityworker_ami_id       = var.cityworker_version == "most_recent" ? data.aws_ami.most_recent_cityworker_ami.id : data.aws_ami.particular_cityworker_ami.id
 cityworker_version      = var.cityworker_version == "most_recent" ? data.aws_ami.most_recent_cityworker_ami.tags["Version"] : data.aws_ami.particular_cityworker_ami.tags["Version"]
}

data "template_file" "api_cityworker_cloud_init" {
  count     = var.cityworker_api_hosts
  template  = file("${path.module}/cloud-init/cityworker_host.yml")
  vars = {
    application = "api"
  }
}

resource "aws_instance" "api_cityworker_host" {
  count                       = var.cityworker_api_hosts
  ami                         = local.cityworker_ami_id
  instance_type               = "t2.small"
  user_data                   = data.template_file.api_cityworker_cloud_init.*.rendered[count.index]
  iam_instance_profile        = local.cityworker_host_profile
  subnet_id                   = aws_subnet.city_private_subnet.id
  monitoring                  = true
  vpc_security_group_ids      = [aws_security_group.city_servers.id]
  associate_public_ip_address = false


  lifecycle {
    create_before_destroy = true
  }
tags = {
    District    = "cityworker"
    Usage       = "api"
    Name        = "${format("apiworker%01d", count.index + 1)}-${replace(local.cityworker_version, ".", "")}${terraform.workspace != "prod" ? terraform.workspace : ""}"
    Role        = "host"
    Environment = terraform.workspace
  }

  depends_on = [
    "aws_vpc.city_vpc", 
    "aws_instance.dmz", 
    "aws_instance.city_host"
    ]
}

data "template_file" "holepunch_cityworker_cloud_init" {
  count     = var.cityworker_holepunch_hosts
  template  = file("${path.module}/cloud-init/cityworker_host.yml")
  vars = {
    application = "holepunch"
  }
}

resource "aws_instance" "holepunch_cityworker_host" {
  count                       = var.cityworker_holepunch_hosts
  ami                         = local.cityworker_ami_id
  instance_type               = "t2.small"
  user_data                   = data.template_file.holepunch_cityworker_cloud_init.*.rendered[count.index]
  iam_instance_profile        = local.cityworker_host_profile
  subnet_id                   = aws_subnet.city_private_subnet.id
  monitoring                  = true
  vpc_security_group_ids      = [aws_security_group.city_servers.id]
  associate_public_ip_address = false


  lifecycle {
    create_before_destroy = true
  }
tags = {
    District    = "cityworker"
    Usage       = "holepunch"
    Name        = "${format("holepunchworker%01d", count.index + 1)}-${replace(local.cityworker_version, ".", "")}${terraform.workspace != "prod" ? terraform.workspace : ""}"
    Role        = "host"
    Environment = terraform.workspace
  }

  depends_on = [
    "aws_vpc.city_vpc", 
    "aws_instance.dmz", 
    "aws_instance.city_host"
    ]
}

data "template_file" "userland_cityworker_cloud_init" {
  count     = var.cityworker_userland_hosts
  template  = file("${path.module}/cloud-init/cityworker_host.yml")
  vars = {
    application = "userland"
  }
}

resource "aws_instance" "userland_cityworker_host" {
  count                       = var.cityworker_userland_hosts
  ami                         = local.cityworker_ami_id
  instance_type               = "t2.small"
  user_data                   = data.template_file.userland_cityworker_cloud_init.*.rendered[count.index]
  iam_instance_profile        = local.cityworker_host_profile
  subnet_id                   = aws_subnet.city_private_subnet.id
  monitoring                  = true
  vpc_security_group_ids      = [aws_security_group.city_servers.id]
  associate_public_ip_address = false


  lifecycle {
    create_before_destroy = true
  }
tags = {
    District    = "cityworker"
    Usage       = "userland"
    Name        = "${format("userlandworker%01d", count.index + 1)}-${replace(local.cityworker_version, ".", "")}${terraform.workspace != "prod" ? terraform.workspace : ""}"
    Role        = "host"
    Environment = terraform.workspace
  }

  depends_on = [
    "aws_vpc.city_vpc", 
    "aws_instance.dmz", 
    "aws_instance.city_host"
    ]
}