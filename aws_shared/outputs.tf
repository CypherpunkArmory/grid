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
