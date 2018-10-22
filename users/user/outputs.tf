output "aws_password" {
  value = "${aws_iam_user_login_profile.login.encrypted_password}"
}

output "aws_secret_key" {
  value = "${aws_iam_access_key.access_key.encrypted_secret}"
}

output "username" {
  value = "${aws_iam_user.user.name}"
}

output "github_name" {
  value = "${github_membership.github.username}"
}
