data "aws_route53_zone" "holepunch" {
  name = "holepunch.io."
  private_zone = false
}

resource "aws_route53_record" "api" {
  zone_id = "${data.aws_route53_zone.holepunch.zone_id}"
  name = "api.holepunch.io"
  type = "A"
  ttl = "300"
  records = ["${aws_eip.city_lb_ip.public_ip}"]
}

resource "aws_route53_record" "api" {
  zone_id = "${data.aws_route53_zone.holepunch.zone_id}"
  name = "*.holepunch.io"
  type = "A"
  ttl = "300"
  records = ["${aws_eip.city_lb_ip.public_ip}"]
}
