variable "github_token" {}

provider "aws" {
  version        = "~> 1.34"
  region         = "us-west-2"
}

provider "github" {
  version = "~> 1.2"
  organization = "CypherpunkArmory"
  token        = "${var.github_token}"
}

module "aws" {
  source = "./aws"
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

