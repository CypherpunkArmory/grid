# These are predfined Amazon Policy ARNS

data "aws_iam_policy" "administrator" {
  arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

data "aws_iam_policy" "developers" {
  arn = "arn:aws:iam::aws:policy/job-function/SystemAdministrator"
}

data "aws_iam_policy" "change_password" {
 arn = "arn:aws:iam::aws:policy/IAMUserChangePassword"
}

# AWS IAM GROUPS

# The "Admin" group is not managed by Terraform
data "aws_iam_group" "admins" {
  group_name = "Admins"
}

resource "aws_iam_group" "developers" {
  name = "Developers"
}

resource "aws_iam_group_policy_attachment" "developers_policy" {
  group = "${aws_iam_group.developers.name}"
  policy_arn = "${data.aws_iam_policy.developers.arn}"
}

resource "aws_iam_group_policy_attachment" "change_password_policy" {
  group = "${aws_iam_group.developers.name}"
  policy_arn = "${data.aws_iam_policy.change_password.arn}"
}
