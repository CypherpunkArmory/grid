# City VPC

resource "aws_vpc" "city_vpc" {
  cidr_block                       = "172.31.0.0/16"
  enable_classiclink               = false
  enable_classiclink_dns_support   = false
  enable_dns_hostnames             = true
  enable_dns_support               = true
  instance_tenancy                 = "default"

  tags = {
    Name        = terraform.workspace
    District    = "city"
    Usage       = "app"
    Environment = terraform.workspace
  }
}

# Subnet CIDR Ranges


# Put PUBLIC SERVERS in this subnet
resource "aws_subnet" "city_vpc_subnet" {
  vpc_id                  = aws_vpc.city_vpc.id
  cidr_block              = "172.31.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2b"

  tags = {
    Name        = "${terraform.workspace}-city"
    District    = "city"
    Environment = terraform.workspace
  }
}

#Put PRIVATE SERVERS in this subnet
resource "aws_subnet" "city_private_subnet" {
  vpc_id                  = aws_vpc.city_vpc.id
  cidr_block              = "172.31.3.0/24"
  availability_zone       = "us-west-2b"

  tags = {
    Name        = "${terraform.workspace}-servers"
    District    = "city"
    Usage       = "app"
    Environment = terraform.workspace
  }
}

# There is an additional subnet in the 173.16.0.0/16 CIDR which is
# reserved for VPN clients.

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.city_vpc.id}"

  tags = {
    Name        = terraform.workspace
    District    = "city"
    Usage       = "app"
    Environment = terraform.workspace
  }
}


# Default Route Table for VPC in the 172.31.1.0/24 CIDR Range (Servers)

resource "aws_route_table" "city_route_table" {
  vpc_id = aws_vpc.city_vpc.id

  tags = {
    Name        = "${terraform.workspace}-city_public"
    District    = "city"
    Usage       = "infra"
    Environment = terraform.workspace
  }
}

resource "aws_route" "default_route" {
  route_table_id          = aws_route_table.city_route_table.id
  destination_cidr_block  = "0.0.0.0/0"
  gateway_id              = aws_internet_gateway.gw.id
}

resource "aws_route" "vpn_route" {
  route_table_id          = aws_route_table.city_route_table.id
  destination_cidr_block  = "172.16.0.0/16"
  instance_id             = aws_instance.dmz.id
}

resource "aws_main_route_table_association" "city_main_route" {
  vpc_id         = aws_vpc.city_vpc.id
  route_table_id = aws_route_table.city_route_table.id
}

# Default Route Table for the Private Subnet for Lambda

resource "aws_route_table" "private_route_table" {
  vpc_id = "${aws_vpc.city_vpc.id}"

  tags = {
    Name        = "${terraform.workspace}-city_private"
    District    = "city"
    Usage       = "app"
    Environment = terraform.workspace
  }
}

resource "aws_route" "private_route" {
  route_table_id          = aws_route_table.private_route_table.id
  destination_cidr_block  = "0.0.0.0/0"
  instance_id             = aws_instance.dmz.id
}

resource "aws_route" "private_vpn_route" {
  route_table_id          = aws_route_table.private_route_table.id
  destination_cidr_block  = "172.16.0.0/16"
  instance_id             = aws_instance.dmz.id
}

resource "aws_route_table_association" "city_private_subnet_route" {
  subnet_id      = aws_subnet.city_private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

# Elastic IPS - Only in prod

resource "aws_eip" "city_lb_ip" {
  count     = terraform.workspace == "prod" ? 1 : 0
  instance  = aws_instance.city_lb.id
  vpc       = true

  depends_on = ["aws_internet_gateway.gw"]

  tags = {
    District    = "city"
    Usage       = "app"
    Role        = "lb"
    Environment = terraform.workspace
  }
}

resource "aws_eip" "city_tcplb_ip" {
  count         = terraform.workspace == "prod" ? 1 : 0
  instance      = aws_instance.city_tcplb.id
  vpc           = true

  depends_on = ["aws_internet_gateway.gw"]

  tags = {
    District    = "city"
    Usage       = "app"
    Role        = "lb"
    Environment = terraform.workspace
  }
}

resource "aws_eip" "dmz_ip" {
  count     = terraform.workspace == "prod" ? 1 : 0
  instance  = aws_instance.dmz.id
  vpc       = true

  depends_on = ["aws_internet_gateway.gw"]

  tags = {
    District    = "dmz"
    Usage       = "infra"
    Role        = "vpn"
    Environment = terraform.workspace
  }
}
