variable "github_token" {}
variable "github_org" {}
variable "datadog_app_key" {}
variable "datadog_api_key" {}
variable "aws_region" {}
variable "output_directory" {}
variable "rollbar_token" {}
variable "min_calver" {}
variable "jwt_secret_key" {}
variable "rds_password" {}
variable "lets_encrypt_email" {}
variable "cloudflare_email" {}
variable "cloudflare_token" {}
variable "docker_bot_pass" {}
variable "kms_key_id" {}

provider "aws" {
  version        = "~> 2.16"
  region         = "${var.aws_region}"
}

provider "local" {
  version  = "~> 1.1"
}

provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

provider "null" {
  version  = "~> 2.1"
}

provider "cloudflare" {
  email = "${var.cloudflare_email}"
  token = "${var.cloudflare_token}"
}

provider "tls" { }

provider "github" {
  version = "~> 1.2"
  organization = "${var.github_org}"
  token        = "${var.github_token}"
}

provider "datadog" {
  version = "~> 1.7"
  api_key = "${var.datadog_api_key}"
  app_key = "${var.datadog_app_key}"
}
