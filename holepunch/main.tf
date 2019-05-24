terraform {
  backend "s3" {
    bucket = "userland.tech.terraform"
    key = "holepunch.tfstate"
    region = "us-west-2"
  }
}

data "terraform_remote_state" "aws" {
  backend = "s3"
  workspace = "${terraform.workspace}"
  config {
    bucket = "userland.tech.terraform"
    key = "aws.tfstate"
    region = "us-west-2"
  }
}

data "terraform_remote_state" "aws_shared" {
  backend = "s3"
  config {
    bucket = "userland.tech.terraform"
    key = "aws_shared.tfstate"
    region = "us-west-2"
  }
}

provider "vault" {
  address = "http://vault.service.city.consul:8200"
}

provider "nomad" {
  address = "http://nomad.service.city.consul:4646"
}

provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "ssh_deploy_version" {
  default = ""
}

variable "holepunch_deploy_version" {
  default = ""
}

variable "min_calver" {}
variable "rollbar_token" {}

locals {
  api_domain = "${terraform.workspace == "prod" ? "holepunch.io" : join(".", list(terraform.workspace, "orbtestenv.net"))}"
  ssh_deploy_version_default = "${ coalesce(var.ssh_deploy_version, "develop") }"
  holepunch_deploy_version_default = "${ coalesce(var.holepunch_deploy_version, "develop") }"
  account_key_pem = "${data.terraform_remote_state.aws_shared.acme_registration_private_key}"
}

resource "random_id" "jwt_secret_key" {
  keepers = {
    workspace = "${terraform.workspace}"
  }

  byte_length = 256
}

resource vault_generic_secret "holepunch_secrets" {
  path = "secret/holepunch"
  data_json = <<EOH
{
  "DATABASE_URL": "${data.terraform_remote_state.aws.database_endpoint}",
  "JWT_SECRET_KEY": "${random_id.jwt_secret_key.hex }" ,
  "MAIL_USERNAME": "${data.terraform_remote_state.aws_shared.emailer_login}",
  "MAIL_PASSWORD": "${data.terraform_remote_state.aws_shared.emailer_password}",
  "ROLLBAR_ENV": "${terraform.workspace}",
  "ROLLBAR_TOKEN": "${var.rollbar_token}",
  "RQ_REDIS_URL": "${data.terraform_remote_state.aws.holepunch_redis_endpoint}",
  "MIN_CALVER": "${var.min_calver}"
}
EOH
}

resource "acme_certificate" "orbtestenv_certificate" {
  count = "${terraform.workspace != "prod" ? 1 : 0}"
  account_key_pem = "${local.account_key_pem}"
  common_name = "api.${local.api_domain}"

  dns_challenge {
    provider = "route53"
  }
}

resource "acme_certificate" "holepunchio_certificate" {
  count = "${terraform.workspace == "prod" ? 1 : 0}"
  account_key_pem = "${local.account_key_pem}"
  common_name = "api.holepunch.io"
  min_days_remaining = 30

  dns_challenge {
    provider = "route53"
  }
}

resource vault_generic_secret "domain_certs" {
  count = "${terraform.workspace == "prod" ? 0 : 1 }"
  path = "secret/fabio/certs/api.${local.api_domain}"
  data_json = <<EOH
{
  "cert": ${jsonencode(acme_certificate.orbtestenv_certificate.certificate_pem)},
  "key": ${jsonencode(acme_certificate.orbtestenv_certificate.private_key_pem)},
  "chain": ${jsonencode(acme_certificate.orbtestenv_certificate.issuer_pem)}
}
EOH
}

resource vault_generic_secret "prod_domain_certs" {
  count = "${ terraform.workspace == "prod" ? 1 : 0 }"
  path = "secret/fabio/certs/api.${local.api_domain}"
  data_json = <<EOH
{
  "cert": ${jsonencode(acme_certificate.holepunchio_certificate.certificate_pem)},
  "key": ${jsonencode(acme_certificate.holepunchio_certificate.private_key_pem)},
  "chain": ${jsonencode(acme_certificate.holepunchio_certificate.issuer_pem)}
}
EOH
}

data "template_file" "holepunch_policy" {
  template = "${file("${path.module}/templates/holepunch-policy.tpl.hcl")}"
  vars {
    api_domain = "api.${local.api_domain}"
  }
}

resource "vault_policy" "holepunch_policy" {
  name = "holepunch-policy"
  policy = "${data.template_file.holepunch_policy.rendered}"
}

data "template_file" "env_file" {
  template = "${file("${path.module}/templates/env.tpl")}"
  vars {
    base_domain = "${local.api_domain}"
  }
}

data "template_file" "holepunch_hcl" {
  template = "${file("${path.module}/templates/holepunch.tpl.hcl")}"
  vars {
    deploy_version = "${local.holepunch_deploy_version_default}"
    api_domain = "api.${local.api_domain}"
    env_template = "${data.template_file.env_file.rendered}"
  }
}

resource "nomad_job" "holepunch" {
  jobspec = "${data.template_file.holepunch_hcl.rendered}"
}

data "template_file" "ssh_hcl" {
  template = "${file("${path.module}/templates/ssh.tpl.hcl")}"
  vars {
    deploy_version = "${local.ssh_deploy_version_default}"
  }
}

resource "nomad_job" "ssh" {
  jobspec = "${data.template_file.ssh_hcl.rendered}"
}
