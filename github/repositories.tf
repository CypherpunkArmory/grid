resource "github_repository" "grid" {
  name        = "grid"
  description = "Infrastructure Repo"

  private = "true"

  has_downloads = "false"
  has_issues    = "true"
  has_wiki      = "false"
  has_projects  = "false"

  lifecycle {
    prevent_destroy = true
  }

  allow_merge_commit = "false"
}

resource "github_team_repository" "grid_userland" {
  team_id    = "${github_team.userland.id}"
  repository = "${github_repository.grid.name}"
  permission = "push"
}

resource "github_repository" "discs" {
  name        = "discs"
  description = "Server Build Scripts"

  private = "true"

  has_downloads = "false"
  has_issues    = "true"
  has_wiki      = "false"
  has_projects  = "false"

  lifecycle {
    prevent_destroy = true
  }

  allow_merge_commit = "false"
}

resource "github_team_repository" "discs_userland" {
  team_id    = "${github_team.userland.id}"
  repository = "${github_repository.discs.name}"
  permission = "push"
}


resource "github_repository" "holepunch" {
  name        = "holepunch"
  description = "Holepunch API"

  private = "false"

  has_downloads = "false"
  has_issues    = "true"
  has_wiki      = "false"
  has_projects  = "false"

  lifecycle {
    prevent_destroy = true
  }

  allow_merge_commit = "false"
}

resource "github_team_repository" "holepunch_userland" {
  team_id    = "${github_team.userland.id}"
  repository = "${github_repository.holepunch.name}"
  permission = "push"
}


resource "github_repository" "punch" {
  name        = "punch"
  description = "Holepunch CLI Tool"

  private = "false"

  has_downloads = "true"
  has_issues    = "true"
  has_wiki      = "false"
  has_projects  = "false"

  topics = [
    "cli",
    "ssh-tunnel",
    "golang"
  ]

  lifecycle {
    prevent_destroy = true
  }

  allow_merge_commit = "false"
}

resource "github_team_repository" "punch_userland" {
  team_id    = "${github_team.userland.id}"
  repository = "${github_repository.punch.name}"
  permission = "push"
}
