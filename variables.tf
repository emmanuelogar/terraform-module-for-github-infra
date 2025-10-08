variable "github_organization" {
  type        = string
  description = "The name of the GitHub organization."
}

# --- GitHub App Credentials ---
variable "github_app_id" {
  type        = string
  description = "The ID of the GitHub App used for provider authentication."
  sensitive   = true
}

variable "github_app_installation_id" {
  type        = string
  description = "The installation ID of the GitHub App."
  sensitive   = true
}

variable "github_app_pem_file" {
  type        = string
  description = "The private key (PEM content) of the GitHub App, retrieved from Key Vault."
  sensitive   = true
}

# --- Module Inputs ---

variable "repositories" {
  type = map(object({
    description = optional(string, "")
    visibility  = optional(string, "private")
    auto_init   = optional(bool, true)
  }))
  description = "A map of repositories to create. Key is the repository name."
}

variable "teams" {
  type = map(object({
    description       = optional(string, "")
    privacy           = optional(string, "closed")
    members           = optional(list(string), [])
    repository_access = optional(map(string), {})
  }))
  description = "A map of teams, their members, and repository access rules. Key is the team name."
}

variable "additional_branch_protection_patterns" {
  type        = list(string)
  description = "A list of additional branch patterns (e.g., 'release/*') to protect, besides 'main' and 'develop'."
  default     = []
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
  default = {
    enforce_admins                  = false
    required_approving_review_count = 1
    require_status_checks           = true
    bypass_teams                    = []
    bypass_users                    = []
    bypass_apps                     = []
  }
}

variable "allowed_action_patterns" {
  description = "A list of specific, trusted third-party GitHub Actions to explicitly allow."
  type        = list(string)
  default = [
    "actions/checkout@v4",
    "hashicorp/setup-terraform@v3",
    "azure/login@v1",
    "azure/cli@v2"
  ]
}