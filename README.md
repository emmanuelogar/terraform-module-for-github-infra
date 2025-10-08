# 🛠️ Managing Repositories and Team Access

This guide shows you the simplest way to update the GitHub organization configuration by modifying the **`organization.tfvars`** file in the root directory. This file is the single source of truth for all repository and team definitions.

---

## 1. Managing Repositories and Team Access

All configuration changes (new repos, teams, members) must be made in the **`organization.tfvars`** file. You will update the primary `repositories` and `teams` maps within this file to reflect the desired state of the organization github repositories.

---

## 2. Creating a New Repository

To create a new repository, add a new entry to the `repositories` map in your **`organization.tfvars`** file. The **key** you use must be the exact repository name.

### Example: Create `data-pipeline-ingest`

Locate the `repositories = { ... }` block and add your new entry, defining its required properties:

```hcl
# In: organization.tfvars

repositories = {
  # ... (Existing repositories)

  "data-pipeline-ingest" = {
    description = "Service for ingesting raw data from external sources."
    visibility  = "private"
    auto_init   = true
    additional_branch_patterns = ["hotfix/*"] # optional default is main and develop
  }
}
```

# 3. Managing Team Access to Repositories

This document explains how to grant teams access to a repository (new or existing) by modifying the **`organization.tfvars`** file, which holds all live configuration data.

## Granting Team Access

To manage access, you must update the **`repository_access`** map within the relevant team's definition in the `teams` block of **`organization.tfvars`**.

### Example: Grant `data-team` Push Access to the `data-pipeline-ingest` Repository

1.  Open the **`organization.tfvars`** file.
2.  Locate the `teams = { ... }` block.
3.  Find the team (e.g., `"data-team"`).
4.  Add the target repository name as a key and the desired permission level as its value to the `repository_access` map.

```hcl
# In: organization.tfvars

teams = {
  # ... (Other teams)

  "data-team" = {
    description = "Team responsible for data pipelines and reporting."
    privacy     = "closed"
    members     = ["david", "emma"]
    repository_access = {
      # Grant 'push' (Write) access to the new repository
      "data-pipeline-ingest" = "push" 
      
      # Existing access rules remain unchanged:
      "backend-svc-alpha"    = "pull" 
    }
  }
}
```

# Permission Levels Access Type

This table defines the different permission levels that can be assigned to a GitHub Team for any repository managed by the Terraform module.

| Permission Level | Access Type | Description |
| :--- | :--- | :--- |
| `"pull"` | Read | Read-only access (cloning, viewing files, pulling requests). |
| `"push"` | Write | Read/write access (contributing code, creating branches, merging pull requests). |
| `"admin"` | Admin | Full administrative control (managing settings, webhooks, security alerts, and other team access). |