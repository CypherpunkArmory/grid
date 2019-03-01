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
    Environment = "${var.environment}"
  }
}

resource "aws_subnet" "city_vpc_subnet" {
  vpc_id = "${aws_vpc.city_vpc.id}"
  cidr_block = "172.31.1.0/24"
  map_public_ip_on_launch = true

  tags {
    District = "city"
    Usage = "app"
    Environment = "${var.environment}"
  }
}

resource "aws_route_table" "city_route_table" {
  vpc_id = "${aws_vpc.city_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "igw-31dcf457"
  }

  route {
    cidr_block = "172.16.0.0/16"
    instance_id = "${aws_instance.dmz.id}"
  }

  tags = {
    Name = "city"
    Environment = "${var.environment}"
  }
}

resource "aws_main_route_table_association" "city_main_route" {
  vpc_id         = "${aws_vpc.city_vpc.id}"
  route_table_id = "${aws_route_table.city_route_table.id}"
}

resource "aws_eip" "city_lb_ip" {
  instance = "${aws_instance.city_lb.id}"
  vpc = true

  tags {
    District = "city"
    Usage = "app"
    Role = "lb"
    Environment = "${var.environment}"
  }
}

resource "aws_eip" "dmz_ip" {
  instance = "${aws_instance.dmz.id}"
  vpc = true

  tags {
    District = "dmz"
    Usage = "infra"
    Role = "vpn"
    Environment = "${var.environment}"
  }
}
