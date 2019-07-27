 locals {
  city_host_profile = "${data.terraform_remote_state.aws_shared.city_host_profile_name}"
  city_ami_id = "${var.city_version == "most_recent" ? data.aws_ami.most_recent_city_ami.id : data.aws_ami.particular_city_ami.id}"
  city_version = "${var.city_version == "most_recent" ? data.aws_ami.most_recent_city_ami.tags["Version"] : data.aws_ami.particular_city_ami.tags["Version"]}"
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

  depends_on = ["aws_vpc.city_vpc"]
}
