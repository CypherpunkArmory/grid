resource "aws_vpc" "build_vpc" {
  cidr_block                     = "172.31.0.0/16"
  enable_classiclink             = false
  enable_classiclink_dns_support = false
  enable_dns_hostnames           = true
  enable_dns_support             = true
  instance_tenancy               = "default"

  tags = {
    District    = "waste"
    Usage       = "infra"
    Environment = terraform.workspace
  }
}

resource "aws_subnet" "build_vpc_subnet" {
  vpc_id                  = aws_vpc.build_vpc.id
  cidr_block              = "172.31.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2c"

  tags = {
    District = "waste"
    Usage    = "infra"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.build_vpc.id

  tags = {
    District    = "waste"
    Usage       = "infra"
    Environment = terraform.workspace
  }
}

resource "aws_route_table" "build_route_table" {
  vpc_id = aws_vpc.build_vpc.id

  tags = {
    Name        = "build_public"
    District    = "waste"
    Usage       = "infra"
    Environment = terraform.workspace
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.build_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_main_route_table_association" "build_main_route" {
  vpc_id         = aws_vpc.build_vpc.id
  route_table_id = aws_route_table.build_route_table.id
}

