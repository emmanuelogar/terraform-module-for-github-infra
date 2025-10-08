output "repositories" {
  value = {
    for k, v in github_repository.this : k => {
      name           = v.name
      id             = v.repo_id
      full_name      = v.full_name
      default_branch = v.default_branch
    }
  }
}
