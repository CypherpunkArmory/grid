terraform {
  backend "s3" {
    bucket = "userland.tech.terraform"
    key    = "users.tfstate"
    region = "us-west-2"
    # path = "./terraform.tfstate"
  }
}

data "terraform_remote_state" "aws_shared" {
  backend = "s3"
  config = {
    bucket = "userland.tech.terraform"
    key    = "aws_shared.tfstate"
    region = "us-west-2"
  }
}

data "terraform_remote_state" "github" {
  backend = "s3"
  config = {
    bucket = "userland.tech.terraform"
    key    = "github.tfstate"
    region = "us-west-2"
  }
}

# Prater
module "prater" {
  source           = "./user"
  username         = "prater"
  email            = "prater@londontrustmedia.com"
  keybase_name     = "stephenprater"
  github_name      = "stephenprater"
  github_role      = "admin"
  name             = "Stephen Prater"
  userland_team_id = data.terraform_remote_state.github.outputs.userland_team_id
}

# Corbin

module "corbin" {
  source           = "./user"
  username         = "corbin"
  keybase_name     = "corbinlc"
  github_name      = "corbinlc"
  github_role      = "admin"
  name             = "Corbin Champion"
  userland_team_id = data.terraform_remote_state.github.outputs.userland_team_id
}

# Andrew

module "andrew" {
  source           = "./user"
  username         = "andrew"
  keybase_name     = "andrewscibek"
  github_name      = "AndrewScibek"
  github_role      = "admin"
  name             = "Andrew Scibek"
  userland_team_id = data.terraform_remote_state.github.outputs.userland_team_id
}

# Matthew

module "matthew" {
  source           = "./user"
  username         = "matthew"
  keybase_name     = "matt_tighe"
  github_name      = "MatthewTighe"
  github_role      = "admin"
  name             = "Matthew Tighe"
  userland_team_id = data.terraform_remote_state.github.outputs.userland_team_id
}

# Thomas

module "thomas" {
  source           = "./user"
  username         = "thomas"
  keybase_name     = "lithogen"
  github_name      = "luongthomas"
  github_role      = "admin"
  name             = "Thomas Luong"
  userland_team_id = data.terraform_remote_state.github.outputs.userland_team_id
}

module "chris" {
  source           = "./user"
  username         = "schafer"
  keybase_name     = "xophere"
  github_name      = "xophere"
  github_role      = "admin"
  name             = "Chris Schafer"
  userland_team_id = data.terraform_remote_state.github.outputs.userland_team_id
}

resource "aws_iam_group_membership" "admins" {
  name  = "admin_membership"
  group = data.terraform_remote_state.aws_shared.outputs.admin_group_name
  users = [
    module.prater.username,
    module.corbin.username,
  ]
}

resource "aws_iam_group_membership" "developers" {
  name  = "developers_membership"
  group = data.terraform_remote_state.aws_shared.outputs.dev_group_name
  users = [
    module.prater.username,
    module.corbin.username,
    module.andrew.username,
    module.matthew.username,
    module.thomas.username,
    module.chris.username,
  ]
}

