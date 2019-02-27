data "aws_route53_zone" "holepunch" {
  name = "holepunch.io."
  private_zone = false
}

resource "aws_route53_zone" "hole_ly" {
  name = "hole.ly"
}

resource "aws_route53_record" "holely_wildcard" {
  zone_id = "${aws_route53_zone.hole_ly.zone_id}"
  name = "*.hole.ly"
  type = "A"
  ttl = "300"
  records = ["${aws_eip.dmz_ip.public_ip}"]
}

resource "aws_route53_record" "holepunch_api" {
  zone_id = "${data.aws_route53_zone.holepunch.zone_id}"
  name = "api.holepunch.io"
  type = "A"
  ttl = "300"
  records = ["${aws_eip.city_lb_ip.public_ip}"]
}

resource "aws_route53_record" "holepunch_wildcard" {
  zone_id = "${data.aws_route53_zone.holepunch.zone_id}"
  name = "*.holepunch.io"
  type = "A"
  ttl = "300"
  records = ["${aws_eip.city_lb_ip.public_ip}"]
}
