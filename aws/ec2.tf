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


variable "city_hosts" {
  default = 3
}

data "template_file" "city_cloud_init" {
  count = "${var.city_hosts}"
  template = "${file("${path.module}/cloud-init/city_host.yml")}"
  vars {
    hostname = "${format("city%01d", count.index + 1)}"
    datadog_api_key = "${var.datadog_api_key}"
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
  iam_instance_profile = "${aws_iam_instance_profile.city_host_profile.name}"
  subnet_id = "${aws_subnet.city_vpc_subnet.id}"
  monitoring = true
  vpc_security_group_ids = ["${aws_security_group.city_servers.id}"]

  lifecycle {
    create_before_destroy = 1
  }

  tags {
    District = "city"
    Usage = "app"
    Name = "${format("city%01d", count.index + 1)}"
    Role = "host"
  }
}

data "template_file" "city_lb_cloud_init" {
  template = "${file("${path.module}/cloud-init/city_lb.yml")}"
  vars {
    hostname = "city-lb"
    lb_district = "city"
  }
}

resource "aws_instance" "city_lb" {
  ami = "${data.aws_ami.lb_ami.id}"
  instance_type = "t2.micro"
  user_data = "${data.template_file.city_lb_cloud_init.rendered}"
  iam_instance_profile = "${aws_iam_instance_profile.city_host_profile.name}"
  subnet_id = "${aws_subnet.city_vpc_subnet.id}"
  monitoring = true
  vpc_security_group_ids = ["${aws_security_group.city_servers.id}"]

  lifecycle {
    create_before_destroy = 1
  }

  tags {
    District = "city"
    Usage = "app"
    Name = "city_lb"
    Role = "lb"
  }
}


resource "aws_vpc" "city_vpc" {
  cidr_block                       = "172.31.0.0/16"
  enable_classiclink               = false
  enable_classiclink_dns_support   = false
  enable_dns_hostnames             = true
  enable_dns_support               = true
  instance_tenancy                 = "default"

  tags {
    District = "city"
    Usage = "app"
  }
}

resource "aws_subnet" "city_vpc_subnet" {
  vpc_id = "${aws_vpc.city_vpc.id}"
  cidr_block = "172.31.1.0/24"
  map_public_ip_on_launch = true

  tags {
    District = "city"
    Usage = "app"
  }
}
