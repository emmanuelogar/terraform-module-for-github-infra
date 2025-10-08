# --- 1. Repository Definitions ---
repositories = {
  "platform-terraform" = {
    description = "Root repository for infrastructure as code."
    visibility  = "private"
    auto_init   = true
  }

 # --- New Repo Addition ---
    "service-api-beta" = {
      description = "New beta microservice for internal API."
      visibility  = "private"
      auto_init   = true
    }
}


# --- 2. Team Definitions ---
teams = {
  "platform-automation" = {
    description = "Platform automation & CI/CD."
    privacy     = "closed"
    members     = ["tayoayodele"] # Add/remove members here
    repository_access = {
      "platform-terraform" = "admin"
      "service-api-beta"   = "push"          # Optional: Add access to another repo required access is pull (read-only), push(for developers), maintain (senior developers), admin (platform or Devops engineers)
    }
  }

    # --- New Team Addition ---
    "Devops" = {
      description = "Backend service developers."
      privacy     = "closed"
      members     = ["tayoayodele", "anotheruser"] # Add/remove members here
      repository_access = {
        "service-api-beta" = "push" # Grant access to the new repo
      }
    }
}

