output "github_users" {
  value = [
    "${module.prater.github_name}",
    "${module.corbin.github_name}",
    "${module.andrew.github_name}",
    "${module.matthew.github_name}",
    "${module.thomas.github_name}"
    "${module.brandon.github_name}"
  ]
}
