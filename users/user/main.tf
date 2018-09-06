locals {
  username = "${var.username}@userland.tech"
}

resource "aws_iam_user" "user" {
  name = "${local.username}"
  force_destroy = "false"
}

resource "aws_iam_access_key" "access_key" {
  user = "${local.username}"
  pgp_key = "keybase:${var.keybase_name}"
}

resource "aws_iam_user_login_profile" "login" {
  user    = "${local.username}"
  pgp_key = "keybase:${var.keybase_name}"
}

resource "github_membership" "github" {
  username = "${var.github_name}"
  role = "${var.github_role}"
}

resource "github_team_membership" "userland" {
  team_id  = "${var.userland_team_id}"
  username = "${var.github_name}"
  role     = "${var.github_role == "admin" ? "maintainer" : "member" }"
}
