resource "aws_ses_domain_identity" "holepunch" {
  domain = "holepunch.io"
}

resource "aws_route53_record" "holepunch_amazonses_verification_record" {
  zone_id = "${ aws_route53_zone.holepunch.zone_id }"
  name = "_amazonses.holepunch.io"
  type = "TXT"
  ttl = "1800"
  records = ["${aws_ses_domain_identity.holepunch.verification_token}"]
}

resource "aws_ses_domain_dkim" "holepunch" {
  domain = "${aws_ses_domain_identity.holepunch.domain}"
}

resource "aws_route53_record" "holepunch_amazonses_dkim_verification_record" {
  count   = 3
  zone_id = "${ aws_route53_zone.holepunch.zone_id }"
  name    = "${element(aws_ses_domain_dkim.holepunch.dkim_tokens, count.index)}._domainkey.holepunch.io"
  type    = "CNAME"
  ttl     = "1800"
  records = ["${element(aws_ses_domain_dkim.holepunch.dkim_tokens, count.index)}.dkim.amazonses.com"]
}


# Test Environment Emails

resource "aws_ses_domain_identity" "orbtestenv" {
  domain = "orbtestenv.net"
}

resource "aws_route53_record" "orbtestenv_amazonses_verification_record" {
  zone_id = "${aws_route53_zone.orbtestenv.zone_id}"
  name = "_amazonses.orbtestenv.net"
  type = "TXT"
  ttl = "1800"
  records = ["${aws_ses_domain_identity.orbtestenv.verification_token}"]
}

resource "aws_ses_domain_dkim" "orbtestenv" {
  domain = "${aws_ses_domain_identity.orbtestenv.domain}"
}

resource "aws_route53_record" "orbtestenv_amazonses_dkim_verification_record" {
  count   = 3
  zone_id = "${aws_route53_zone.orbtestenv.zone_id}"
  name    = "${element(aws_ses_domain_dkim.holepunch.dkim_tokens, count.index)}._domainkey.orbtestenv.net"
  type    = "CNAME"
  ttl     = "1800"
  records = ["${element(aws_ses_domain_dkim.holepunch.dkim_tokens, count.index)}.dkim.amazonses.com"]
}



