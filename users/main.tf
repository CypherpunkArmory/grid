terraform {
  backend "s3" {
    bucket = "userland.tech.terraform"
    key = "users.tfstate"
    region = "us-west-2"
    # path = "./terraform.tfstate"
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

data "terraform_remote_state" "github" {
  backend = "s3"
  config {
    bucket = "userland.tech.terraform"
    key = "github.tfstate"
    region = "us-west-2"
  }
}

# Prater
module "prater" {
  source = "./user"
  username = "prater@userland.tech"
  keybase_name = "stephenprater"
  github_name = "stephenprater"
  github_role = "admin"
  name = "Stephen Prater"
  userland_team_id = "${data.terraform_remote_state.github.userland_team_id}"
}

# Corbin

module "corbin" {
  source = "./user"
  username = "corbin@userland.tech"
  keybase_name = "corbinlc"
  github_name = "corbinlc"
  github_role = "admin"
  name = "Corbin Champion"
  userland_team_id = "${data.terraform_remote_state.github.userland_team_id}"
}

# Andrew

module "andrew" {
  source = "./user"
  username = "andrew@userland.tech"
  keybase_name = "andrewscibek"
  github_name = "AndrewScibek"
  github_role = "admin"
  name = "Andrew Scibek"
  userland_team_id = "${data.terraform_remote_state.github.userland_team_id}"
}

# Matthew

module "matthew" {
  source = "./user"
  username = "matthew@userland.tech"
  keybase_name = "matt_tighe"
  github_name = "MatthewTighe"
  github_role = "admin"
  name = "Matthew Tighe"
  userland_team_id = "${data.terraform_remote_state.github.userland_team_id}"
}

# Thomas

module "thomas" {
  source = "./user"
  username = "thomas@userland.tech"
  keybase_name = "lithogen"
  github_name = "luongthomas"
  github_role = "admin"
  name = "Thomas Luong"
  userland_team_id = "${data.terraform_remote_state.github.userland_team_id}"
}

# Brandon Presley (Contractor)

module "brandon" {
  source = "./user"
  username = "brandon"
  email = "presley.brandon@gmail.com"
  keybase_name = "aytch"
  github_name = "aytch"
  github_role = "member"
  name = "Brandon Presley"
  userland_team_id = "${data.terraform_remote_state.github.userland_team_id}"
}

resource "aws_iam_group_membership" "admins" {
  name = "admin_membership"
  group = "${data.terraform_remote_state.aws_shared.admin_group_name}"
  users = [
    "${module.prater.username}",
    "${module.corbin.username}"
  ]
}

resource "aws_iam_group_membership" "developers" {
  name = "developers_membership"
  group = "${data.terraform_remote_state.aws_shared.dev_group_name}"
  users = [
    "${module.prater.username}",
    "${module.corbin.username}",
    "${module.andrew.username}",
    "${module.matthew.username}",
    "${module.thomas.username}",
    "${module.brandon.username}"
  ]
}
