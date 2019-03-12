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
