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


variable "city_hosts" {
  default = 3
}

data "template_file" "city_cloud_init" {
  count = "${var.city_hosts}"
  template = "${file("${path.module}/cloud-init/city_host.yml")}"
  vars {
    hostname = "${format("city%01d", count.index + 1)}-${replace(data.aws_ami.city_ami.tags["Version"], ".", "")}"
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
    Name = "${format("city%01d", count.index + 1)}-${replace(data.aws_ami.city_ami.tags["Version"], ".", "")}"
    Role = "host"
  }

  provisioner "remote-exec" {
    when = "destroy"
    inline = [
      "nomad node eligibility -disable -self",
      "nomad node drain -self",
      "sleep 15", # this should wait until the new servers are stable and a leader election can be performed when we leave
      "consul leave"
    ]
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
  ami                    = "${data.aws_ami.lb_ami.id}"
  instance_type          = "t2.micro"
  user_data              = "${data.template_file.city_lb_cloud_init.rendered}"
  iam_instance_profile   = "${aws_iam_instance_profile.city_host_profile.name}"
  subnet_id              = "${aws_subnet.city_vpc_subnet.id}"
  monitoring             = true
  vpc_security_group_ids = ["${aws_security_group.city_servers.id}"]

  lifecycle {
    create_before_destroy = 1
  }

  tags {
    District = "city"
    Usage    = "app"
    Name     = "city_lb"
    Role     = "lb"
    Environment = "${var.environment}"
  }

  provisioner "remote-exec" {
    when             = "destroy"
    inline           = [
      "consul leave"
    ]
  }
}

data "template_file" "dmz_host_cloud_init" {
  template = "${file("${path.module}/cloud-init/dmz_host.yml")}"
  vars {
    hostname = "dmz"
    openvpn_server = "${indent(6, file("/keybase/team/userland/openvpn_server.conf"))}"
  }
}


resource "aws_instance" "dmz" {
  ami                    = "${data.aws_ami.dmz_ami.id}"
  instance_type          = "t2.micro"
  iam_instance_profile   = "${aws_iam_instance_profile.dmz_host_profile.name}"
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
    Name     = "dmz"
    Role     = "vpn"
    Environment = "${var.environment}"
  }

  provisioner "remote-exec" {
    when             = "destroy"
    inline           = [
      "consul leave"
    ]
  }
}
