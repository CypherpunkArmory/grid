resource "aws_vpc" "build_vpc" {
  cidr_block                       = "172.31.0.0/16"
  enable_classiclink               = false
  enable_classiclink_dns_support   = false
  enable_dns_hostnames             = true
  enable_dns_support               = true
  instance_tenancy                 = "default"

  tags {
    District = "waste"
    Usage = "infra"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_subnet" "build_vpc_subnet" {
  vpc_id = "${aws_vpc.build_vpc.id}"
  cidr_block = "172.31.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-west-2c"

  tags {
    District = "waste"
    Usage = "infra"
    Environment = "${terraform.workspace}"
  }
}

