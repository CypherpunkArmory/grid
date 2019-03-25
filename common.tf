variable "github_token" {}
variable "github_org" {}
variable "datadog_app_key" {}
variable "datadog_api_key" {}
variable "rds_password" {}
variable "aws_region" {}
variable "output_directory" {}

provider "aws" {
  version        = "~> 2.0"
  region         = "${var.aws_region}"
}

provider "local" {
  version  = "~> 1.1"
}

provider "null" {
  version  = "~> 2.1"
}

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
