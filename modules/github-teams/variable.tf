variable "teams" {
  description = "Map of teams to create (key is the team name)."
  type = map(object({
    description       = optional(string, "")
    privacy           = optional(string, "closed")
    members           = optional(list(string), [])
    repository_access = optional(map(string), {}) # Map of repo_name -> permission (e.g., "pull", "push", "admin")
  }))
  default = {}
}

variable "managed_repositories" {
  description = "Map of repository objects managed by the repository module. Used for validation."
  type = map(object({ name = string, id = number, full_name = string,
    default_branch = string
  }))
}