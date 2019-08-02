locals {
  dmz_zone        = terraform.workspace == "prod" ? data.terraform_remote_state.aws_shared.outputs.hole_ly_zone : data.terraform_remote_state.aws_shared.outputs.testinghole_zone
  api_zone        = terraform.workspace == "prod" ? data.terraform_remote_state.aws_shared.outputs.holepunch_zone : data.terraform_remote_state.aws_shared.outputs.orbtestenv_zone
  web_zone        = terraform.workspace == "prod" ? data.terraform_remote_state.aws_shared.outputs.holepunch_zone : data.terraform_remote_state.aws_shared.outputs.orbtestenv_zone
  dmz_domain      = terraform.workspace == "prod" ? "hole.ly" : join(".", [terraform.workspace, "testinghole.com"])
  api_domain      = terraform.workspace == "prod" ? "holepunch.io" : join(".", [terraform.workspace, "orbtestenv.net"])
  account_key_pem = data.terraform_remote_state.aws_shared.outputs.acme_registration_private_key
}


resource "aws_route53_record" "dmz_wildcard" {
  zone_id   = local.dmz_zone
  name      = "*.${local.dmz_domain}"
  type      = "A"
  ttl       = 300
  records   = [terraform.workspace == "prod" ? join("",aws_eip.dmz_ip.*.public_ip) : aws_instance.dmz.public_ip]
}

resource "aws_route53_record" "api_dns" {
  zone_id   = local.api_zone
  name      = "api.${local.api_domain}"
  type      = "A"
  ttl       = "300"
  records   = [terraform.workspace == "prod" ? join("", aws_eip.city_lb_ip.*.public_ip) : aws_instance.city_lb.public_ip]
}

resource "aws_route53_record" "lb_wildcard" {
  zone_id = local.api_zone
  name = "*.${local.api_domain}"
  type = "A"
  ttl = "300"
  records = [terraform.workspace == "prod" ? join("", aws_eip.city_lb_ip.*.public_ip) : aws_instance.city_lb.public_ip]
}

resource "aws_route53_record" "tcplb" {
  zone_id = local.api_zone
  name = "tcp.${local.api_domain}"
  type = "A"
  ttl = "300"
  records = [terraform.workspace == "prod" ? join("", aws_eip.city_tcplb_ip.*.public_ip) : aws_instance.city_tcplb.public_ip]
}
