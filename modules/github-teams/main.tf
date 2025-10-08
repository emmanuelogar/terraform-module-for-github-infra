data "github_team" "this" {
  for_each = var.teams
  slug     = each.key
}

resource "github_team_membership" "member" {
  for_each = {
    for pair in flatten([
      for tname, tcfg in var.teams : [
        for member in lookup(tcfg, "members", []) : {
          team = tname
          user = member
        }
      ]
    ]) : "${pair.team}|${pair.user}" => pair
  }

  team_id  = data.github_team.this[each.value.team].id
  username = each.value.user
  role     = "member" 
}

resource "github_team_repository" "this" {
  for_each = {
    for pair in flatten([
      for tname, tcfg in var.teams : [
        for repo_name, permission in lookup(tcfg, "repository_access", {}) : {
          team       = tname
          repo       = repo_name
          permission = permission
        }
      ]
    ]) : "${pair.team}|${pair.repo}" => pair
    if contains(keys(var.managed_repositories), pair.repo)
  }

  team_id    = data.github_team.this[each.value.team].id
  repository = each.value.repo
  permission = each.value.permission
}