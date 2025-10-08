variable "github_organization" {
  type        = string
  description = "The name of the GitHub organization."
}

variable "repositories" {
  description = "A map of repositories to create (key is the repo name)."
  type = map(object({
    description = optional(string, "")
    visibility  = optional(string, "private")
    auto_init   = optional(bool, true)
    additional_branch_patterns   = optional(list(string), [])
  }))

  validation {
    condition = alltrue([
      for name in keys(var.repositories) : can(regex("^[a-zA-Z0-9._-]+$", name))
    ])
    error_message = "Each repository key in 'repositories' must contain only alphanumeric characters, hyphens (-), periods (.), and underscores (_)."
  }
}

variable "additional_branch_protection_patterns" {
  description = "A list of additional branch patterns (e.g., 'release/*') to apply protection to."
  type        = list(string)
}

variable "branch_protection_defaults" {
  description = "Default settings for branch protection on non-main/non-develop branches."
  type = object({
    enforce_admins                  = bool
    required_approving_review_count = number
    require_status_checks           = bool
    bypass_teams                    = list(string)
    bypass_users                    = list(string)
    bypass_apps                     = list(string)
  })
}

variable "allowed_action_patterns" {
  description = "A list of specific, trusted third-party GitHub Actions to explicitly allow."
  type        = list(string)
}

variable "team_repo_access" {
  description = "Map of existing GitHub team slugs to repositories and permissions"
  type = map(map(string))
  default = {}
}