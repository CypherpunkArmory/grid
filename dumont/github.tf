resource "github_repository" "dumont" {
  name        = "dumont"
  description = "Commune with the Users"

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

resource "github_branch_protection" "dumont" {
  repository = "${github_repository.dumont.name}"
  branch = "master"

  required_status_checks {
    strict = false
  }

  required_pull_request_reviews {
    dismiss_stale_reviews = false
  }
}
