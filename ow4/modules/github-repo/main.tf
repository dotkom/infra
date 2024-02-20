resource "github_repository" "repo" {
  name                   = var.name
  description            = var.description
  has_issues             = true
  has_downloads          = "false"
  has_projects           = "false"
  has_wiki               = "false"
  visibility             = var.visibility
  auto_init              = true
  delete_branch_on_merge = true
  archive_on_destroy     = true
}


resource "github_branch_default" "repo" {
  repository = github_repository.repo.name
  branch     = var.default_branch
}

resource "github_branch_protection" "repo" {
  repository_id       = github_repository.repo.node_id
  pattern             = var.default_branch
  enforce_admins      = true
  allows_deletions    = false
  allows_force_pushes = false

  required_status_checks {
    strict   = true
    contexts = var.required_status_checks
  }
}
