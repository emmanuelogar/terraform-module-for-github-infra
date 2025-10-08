resource "github_organization_settings" "this" {
  billing_email                   = "billing@example.com"
  company                         = "Graphnethealth"
  members_can_create_repositories = false
  default_repository_permission = "read"
  members_can_create_public_repositories   = false
  members_can_create_private_repositories  = false
  members_can_create_internal_repositories = false
  members_can_fork_private_repositories = false
}

resource "github_repository" "this" {
  for_each = var.repositories

  name        = each.key
  description = lookup(each.value, "description", "")
  visibility  = lookup(each.value, "visibility", "private")
  auto_init   = lookup(each.value, "auto_init", true)

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_branch" "develop" {
  for_each      = github_repository.this
  repository    = each.value.name
  branch        = "develop"
  source_branch = each.value.default_branch
}

locals {
  repo_branch_protection_pairs = flatten([
    for repo_key, repo_val in github_repository.this : [
      for pattern in toset(concat(
        ["main", "develop"],
        lookup(repo_val, "additional_branch_patterns", [])
      )) : {
        repo_name      = repo_val.name
        branch_pattern = pattern
        is_main        = pattern == "main"
      }
    ]
  ])
}
resource "github_branch_protection" "protection" {
  for_each = {
    for pair in local.repo_branch_protection_pairs :
    "${pair.repo_name}|${pair.branch_pattern}" => pair
  }

  repository_id = github_repository.this[each.value.repo_name].node_id
  pattern       = each.value.branch_pattern

  enforce_admins = each.value.is_main ? true : var.branch_protection_defaults.enforce_admins

  required_pull_request_reviews {
    required_approving_review_count = var.branch_protection_defaults.required_approving_review_count
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = true

    pull_request_bypassers = concat(
      try(var.branch_protection_defaults.bypass_teams, []),
      try(var.branch_protection_defaults.bypass_users, []),
      try(var.branch_protection_defaults.bypass_apps, [])
    )
  }

  required_status_checks {
    strict   = true
    contexts = try(var.branch_protection_defaults.status_check_contexts, [])
  }

}

# resource "github_actions_repository_permissions" "this" {
#   for_each = github_repository.this

#   repository      = each.value.name
#   enabled         = true
#   allowed_actions = "selected"

#   allowed_actions_config {
#     github_owned_allowed = true
#     verified_allowed     = true
#     patterns_allowed     = var.allowed_action_patterns
#   }
# }
# Lookup existing teams (by slug)
