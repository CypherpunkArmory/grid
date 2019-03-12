locals {
  dmz_zone = "${terraform.workspace == "prod" ? data.terraform_remote_state.aws_shared.hole_ly_zone : data.terraform_remote_state.aws_shared.testinghole_zone}"
  api_zone = "${terraform.workspace == "prod" ? data.terraform_remote_state.aws_shared.holepunch_zone : data.terraform_remote_state.aws_shared.orbtestenv_zone}"
  dmz_domain = "${terraform.workspace == "prod" ? "hole.ly" : join(".", list(terraform.workspace, "testinghole.com"))}"
  api_domain = "${terraform.workspace == "prod" ? "holepunch.io" : join(".", list(terraform.workspace, "orbtestenv.net"))}"
}


resource "aws_route53_record" "dmz_wildcard" {
  zone_id = "${local.dmz_zone}"
  name = "*.${local.dmz_domain}"
  type = "A"
  ttl = 300
  records = ["${aws_eip.dmz_ip.public_ip}"]
}

resource "aws_route53_record" "api_dns" {
  zone_id = "${local.api_zone}"
  name = "api.${local.api_domain}"
  type = "A"
  ttl = "300"
  records = ["${aws_eip.city_lb_ip.public_ip}"]
}

resource "aws_route53_record" "lb_wildcard" {
  zone_id = "${local.api_zone}"
  name = "*.${local.api_domain}"
  type = "A"
  ttl = "300"
  records = ["${aws_eip.city_lb_ip.public_ip}"]
}
