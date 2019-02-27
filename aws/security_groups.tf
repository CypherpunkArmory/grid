resource "aws_security_group" "city_servers" {
  name        = "city"
  vpc_id      = "${aws_vpc.city_vpc.id}"
  description = "Allow SSH / HTTP / HTTP(s) traffic to City"

  tags {
    District = "city"
    Usage = "app"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "dmz_server" {
  name        = "dmz"
  vpc_id      = "${aws_vpc.city_vpc.id}"
  description = "Allow UDP OpenVPN traffic to DMZ"

  tags {
    District = "dmz"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "allow_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.city_servers.id}"
}


resource "aws_security_group_rule" "allow_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.city_servers.id}"
}

resource "aws_security_group_rule" "allow_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.city_servers.id}"
}

resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.city_servers.id}"
}

resource "aws_security_group_rule" "subnet_allow_all" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["172.31.0.0/16"]
  security_group_id = "${aws_security_group.city_servers.id}"
}

resource "aws_security_group_rule" "allow_vpn" {
  type              = "ingress"
  from_port         = 1194
  to_port           = 1194
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.dmz_server.id}"
}
