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

resource "github_repository" "holepunch" {
  name        = "holepunch"
  description = "Holepunch API"

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

resource "github_repository" "holepunch_cli" {
  name        = "holepunch_cli"
  description = "Holepunch CLI"

  private = "true"

  has_downloads = "true"
  has_issues    = "true"
  has_wiki      = "false"
  has_projects  = "false"

  lifecycle {
    prevent_destroy = true
  }

  allow_merge_commit = "false"
}
