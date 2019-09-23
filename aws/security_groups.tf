resource "aws_security_group" "city_servers" {
  name        = "city-${terraform.workspace}"
  vpc_id      = aws_vpc.city_vpc.id
  description = "Allow SSH / HTTP / HTTP(s) traffic to City"

  tags = {
    District    = "city"
    Usage       = "app"
    Environment = terraform.workspace
  }
}

resource "aws_security_group" "dmz_server" {
  name        = "dmz-${terraform.workspace}"
  vpc_id      = aws_vpc.city_vpc.id
  description = "Allow UDP OpenVPN traffic to DMZ"

  tags = {
    District    = "dmz"
    Environment = terraform.workspace
  }
}

resource "aws_security_group_rule" "allow_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.city_servers.id
}

resource "aws_security_group_rule" "allow_postgres" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.city_servers.id
}


resource "aws_security_group_rule" "allow_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.city_servers.id
}

resource "aws_security_group_rule" "allow_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.city_servers.id
}

resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.city_servers.id
}

resource "aws_security_group_rule" "subnet_allow_all" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["172.31.0.0/16", "172.16.0.0/16"]
  security_group_id = aws_security_group.city_servers.id
}

resource "aws_security_group_rule" "allow_vpn" {
  type              = "ingress"
  from_port         = 1194
  to_port           = 1194
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.dmz_server.id
}

resource "aws_security_group" "tcplb_servers" {
  name        = "tcplb-${terraform.workspace}"
  vpc_id      = aws_vpc.city_vpc.id
  description = "Allow 22 internal, and 10,000-25,000 for user tcp ports"

  tags = {
    District = "city"
    Usage = "app"
    Environment = terraform.workspace
  }
}

resource "aws_security_group_rule" "allow_all_tcp" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tcplb_servers.id
}

resource "aws_security_group_rule" "subnet_allow_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["172.31.0.0/16", "172.16.0.0/16"]
  security_group_id = aws_security_group.tcplb_servers.id
}

resource "aws_security_group_rule" "subnet_public_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tcplb_servers.id
}

resource "aws_security_group_rule" "allow_tcp_ports" {
  type              = "ingress"
  from_port         = 10000
  to_port           = 25000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tcplb_servers.id
}