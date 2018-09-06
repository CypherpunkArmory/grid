# Prater
module "prater" {
  source = "./user"
  username = "prater"
  keybase_name = "stephenprater"
  github_name = "stephenprater"
  github_role = "member"
  userland_team_id = "${var.userland_team_id}"
}

# Corbin

module "corbin" {
  source = "./user"
  username = "corbin"
  keybase_name = "corbinlc"
  github_name = "corbinlc"
  github_role = "admin"
  userland_team_id = "${var.userland_team_id}"
}

# Andrew

module "andrew" {
  source = "./user"
  username = "andrew"
  keybase_name = "andrewscibek"
  github_name = "AndrewScibek"
  github_role = "member"
  userland_team_id = "${var.userland_team_id}"
}

# Matthew

module "matthew" {
  source = "./user"
  username = "matthew"
  keybase_name = "matt_tighe"
  github_name = "MatthewTighe"
  github_role = "admin"
  userland_team_id = "${var.userland_team_id}"
}

# Thomas

module "thomas" {
  source = "./user"
  username = "thomas"
  keybase_name = "lithogen"
  github_name = "luongthomas"
  github_role = "member"
  userland_team_id = "${var.userland_team_id}"
}

resource "aws_iam_group_membership" "admins" {
  name = "admin_membership"
  group = "${var.aws_admin_group}"
  users = [
    "${module.prater.username}",
    "${module.corbin.username}"
  ]
}
resource "aws_iam_group_membership" "developers" {
  name = "developers_membership"
  group = "${var.aws_dev_group}"
  users = [
    "${module.prater.username}",
    "${module.corbin.username}",
    "${module.andrew.username}",
    "${module.matthew.username}",
    "${module.thomas.username}"
  ]
}

