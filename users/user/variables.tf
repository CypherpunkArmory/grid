variable "username" {
  description = "Users login name / @userland.tech email"
}

variable "keybase_name" {
  description = "The users keybase username"
}

variable "github_name" {
  description = "The users github username"
}

variable "github_role" {
  description = "Users github role - either 'member' or 'admin'"
}

# Shitty workaround until terraform 0.12
variable "userland_team_id" {
  description = "Userland Team ID"
}

