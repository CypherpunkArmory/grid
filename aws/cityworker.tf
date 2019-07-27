locals {
 # Note the below uses the city profile
  cityworker_host_profile = "${data.terraform_remote_state.aws_shared.city_host_profile_name}"
  cityworker_ami_id = "${var.cityworker_version == "most_recent" ? data.aws_ami.most_recent_cityworker_ami.id : data.aws_ami.particular_cityworker_ami.id}"
  cityworker_version = "${var.cityworker_version == "most_recent" ? data.aws_ami.most_recent_cityworker_ami.tags["Version"] : data.aws_ami.particular_cityworker_ami.tags["Version"]}"
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
  instance_type = "t2.small"
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