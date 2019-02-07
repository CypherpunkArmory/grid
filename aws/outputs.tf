output "admin_group_name" {
  value = "${data.aws_iam_group.admins.group_name}"
}

output "dev_group_name" {
  value = "${aws_iam_group.developers.name}"
}

output "aws_emailer_smtp_password" {
  value = "${aws_iam_user.emailer.ses_smtp_password}"
}
