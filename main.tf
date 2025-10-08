# Configure the GitHub provider using credentials from the CI/CD workflow.
provider "github" {
  owner = var.github_organization
  app_auth {
    id              = var.github_app_id
    installation_id = var.github_app_installation_id
    pem_file        = var.github_app_pem_file
  }
}

# Module to create and manage repositories based on the variable definition.
module "repositories" {
  source = "./modules/github-repo"

  github_organization                   = var.github_organization
  repositories                          = var.repositories
  additional_branch_protection_patterns = var.additional_branch_protection_patterns
  branch_protection_defaults            = var.branch_protection_defaults
  allowed_action_patterns               = var.allowed_action_patterns
}

# Module to create and manage teams and their access to repositories.
module "teams" {
  source = "./modules/github-teams"

  teams                = var.teams
  managed_repositories = module.repositories.repositories
}