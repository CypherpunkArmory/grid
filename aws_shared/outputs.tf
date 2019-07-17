output "admin_group_name" {
  value = "${aws_iam_group.admins.name}"
}

output "dev_group_name" {
  value = "${aws_iam_group.developers.name}"
}

output "city_host_profile_name" {
  value = "${aws_iam_instance_profile.city_host_profile.name}"
}

output "dmz_host_profile_name" {
  value = "${aws_iam_instance_profile.dmz_host_profile.name}"
}

output "lb_host_profile_name" {
  value = "${aws_iam_instance_profile.lb_host_profile.name}"
}

output "emailer_password" {
  value = "${aws_iam_access_key.emailer_key.ses_smtp_password}"
}

output "emailer_login" {
  value = "${aws_iam_access_key.emailer_key.id}"
}

output "acme_registration_private_key" {
  value = "${tls_private_key.pushbutton.private_key_pem}"
}

output "hole_ly_zone" {
  value = "${aws_route53_zone.hole_ly.zone_id}"
}

output "holepunch_zone" {
  value = "${aws_route53_zone.holepunch.zone_id}"
}

output "testinghole_zone" {
  value = "${aws_route53_zone.testinghole.zone_id}"
}

output "orbtestenv_zone" {
  value = "${aws_route53_zone.orbtestenv.zone_id}"
}

output "testpunch_cloudflare_zone" {
  value = "${cloudflare_zone.holepunch_stg_zone.zone}"
}
