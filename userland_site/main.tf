terraform {
  backend "s3" {
    bucket = "userland.tech.terraform"
    key = "userland_site.tfstate"
    region = "us-west-2"
  }
}

data "terraform_remote_state" "aws_shared" {
  backend = "s3"
  config = {
    bucket = "userland.tech.terraform"
    key = "aws_shared.tfstate"
    region = "us-west-2"
  }
}

provider "aws" {
  version        = "~> 2.0"
  region         = "${var.aws_region}"
}

provider "aws" {
  version        = "~> 2.0"
  region = "us-east-1"
  alias = "use1"
}

provider "cloudflare" {
  email = "${var.cloudflare_email}"
  api_token = "${var.cloudflare_token}"
}

variable "aws_region" {}
variable "cloudflare_email" {}
variable "cloudflare_token" {}

locals {
  web_domain = "${terraform.workspace == "prod" ? "userland.tech" : join(".", list(terraform.workspace, "testpunch.io"))}"
  web_zone = "${terraform.workspace == "prod" ? "userland.tech" : "testpunch.io"}"
  account_key_pem = data.terraform_remote_state.aws_shared.outputs.acme_registration_private_key
}

resource "aws_s3_bucket" "userland_site_www" {
  count = "${ terraform.workspace == "prod" ? 1 : 0 }"
  bucket = "www.${local.web_domain}"
  region = "us-west-2"
  acl = "public-read"

  website {
    redirect_all_requests_to = "https://${local.web_domain}"
  }

  tags = {
    Name = "UserLAnd Website Hosting Redirect"
    District = "city"
    Usage = "app"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_s3_bucket" "userland_site" {
  bucket = "${local.web_domain}"
  region = "us-west-2"
  acl = "public-read"
  policy = <<WEB
{
  "Version":"2012-10-17",
  "Statement":[
    {
    "Sid":"PublicReadGetObject",
    "Effect":"Allow",
    "Principal": "*",
    "Action":["s3:GetObject"],
    "Resource":["arn:aws:s3:::${local.web_domain}/*"]
    }
  ]
}
WEB

  force_destroy = "${ terraform.workspace == "prod" ? false : true }"

  website {
    index_document = "index.html"
  }

  tags = {
    Name = "UserLAnd Website Hosting"
    District = "city"
    Usage = "app"
    Environment = "${terraform.workspace}"
  }
}

resource "cloudflare_record" "userland_stg" {
  count = "${ terraform.workspace == "prod" ? 0 : 1 }"
  zone_id = data.terraform_remote_state.aws_shared.outputs.testpunch_cloudflare_zone
  name = "${terraform.workspace}"
  value = "${aws_s3_bucket.userland_site.website_endpoint}"
  type = "CNAME"
  ttl = 1
}

resource "aws_cloudfront_origin_access_identity" "userland_origin_access_identity" {
  count = "${ terraform.workspace == "prod" ? 1 : 0 }"
  comment = "UserLAnd Production Distribution"
}

resource "aws_cloudfront_distribution" "userland_distribution" {
  count = "${ terraform.workspace == "prod" ? 1 : 0 }"

  origin {
    domain_name = "${aws_s3_bucket.userland_site.bucket_regional_domain_name}"
    origin_id = "userland_site"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.userland_origin_access_identity[0].cloudfront_access_identity_path}"
    }
  }

  enabled = true
  is_ipv6_enabled = true
  default_root_object = "index.html"

  aliases = ["userland.tech"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "userland_site"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  tags = {
    Name = "UserLAnd Website Hosting"
    District = "city"
    Usage = "app"
    Environment = "${terraform.workspace}"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = "${aws_acm_certificate.userland_cert[0].arn}"
    ssl_support_method = "sni-only"
  }
}

resource "aws_acm_certificate" "userland_cert" {
  count = "${ terraform.workspace == "prod" ? 1 : 0 }"
  provider = "aws.use1"

  domain_name = "userland.tech"
  validation_method = "DNS"

  tags = {
    Name = "userland.tech certificate"
    District = "city"
    Usage = "app"
    Environment = "${terraform.workspace}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  count = "${ terraform.workspace == "prod" ? 1 : 0 }"
  provider = "aws.use1"
  name    = "${aws_acm_certificate.userland_cert[0].domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.userland_cert[0].domain_validation_options.0.resource_record_type}"
  zone_id = data.terraform_remote_state.aws_shared.outputs.userland_zone
  records = ["${aws_acm_certificate.userland_cert[0].domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "userland_cert" {
  count = "${ terraform.workspace == "prod" ? 1 : 0 }"
  provider = "aws.use1"
  certificate_arn = "${aws_acm_certificate.userland_cert[0].arn}"
  validation_record_fqdns = ["${aws_route53_record.cert_validation[0].fqdn}"]
}

resource "aws_route53_record" "userland_tech" {
  count = "${ terraform.workspace == "prod" ? 1 : 0 }"
  zone_id = data.terraform_remote_state.aws_shared.outputs.userland_zone
  name = "userland.tech"
  type = "A"

  allow_overwrite = true

  alias {
    name = "${aws_cloudfront_distribution.userland_distribution[0].domain_name}"
    zone_id = "${aws_cloudfront_distribution.userland_distribution[0].hosted_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www_userland_tech" {
  count = "${ terraform.workspace == "prod" ? 1 : 0 }"
  zone_id = data.terraform_remote_state.aws_shared.outputs.userland_zone
  name = "www.userland.tech"
  type = "A"

  alias {
    name = "${aws_s3_bucket.userland_site_www[0].website_domain}"
    zone_id = "${aws_s3_bucket.userland_site_www[0].hosted_zone_id}"
    evaluate_target_health = false
  }
}
