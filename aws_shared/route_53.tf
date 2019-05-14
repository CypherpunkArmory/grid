resource "aws_route53_zone" "holepunch" {
  name = "holepunch.io"
}

resource "aws_route53_zone" "hole_ly" {
  name = "hole.ly"
}

# The test env always runs at these domains

resource "aws_route53_zone" "orbtestenv" {
  name = "orbtestenv.net"
}

resource "aws_route53_zone" "testinghole" {
  name = "testinghole.com"
}

resource "tls_private_key" "pushbutton" {
  algorithm = "RSA"
  rsa_bits = 2048
}

resource "acme_registration" "lets_encrypt_reg" {
  depends_on = ["tls_private_key.pushbutton"]
  account_key_pem = "${tls_private_key.pushbutton.private_key_pem}"
  email_address = "${var.lets_encrypt_email}"
}
