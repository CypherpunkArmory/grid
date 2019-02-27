variable "github_token" {}
variable "datadog_app_key" {}
variable "datadog_api_key" {}
variable "environment" {}

provider "aws" {
  version        = "~> 1.57"
  region         = "us-west-2"
}

provider "github" {
  version = "~> 1.2"
  organization = "CypherpunkArmory"
  token        = "${var.github_token}"
}

provider "datadog" {
  api_key = "${var.datadog_api_key}"
  app_key = "${var.datadog_app_key}"
}

module "aws" {
  source = "./aws"
  github_users = "${module.users.github_users}"
  datadog_api_key = "${var.datadog_api_key}"
  environment = "${var.environment}"
}

module "github" {
  source = "./github"
}

module "users" {
  source = "./users"
  aws_admin_group = "${module.aws.admin_group_name}"
  aws_dev_group = "${module.aws.dev_group_name}"
  userland_team_id = "${module.github.userland_team_id}"
}

module "dumont" {
  source = "./dumont"
}

terraform {
  backend "s3" {
    bucket = "userland.tech.terraform"
    key = "terraform.tfstate"
    region = "us-west-2"
  }
}

