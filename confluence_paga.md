# GitHub Organization Terraform Module — Design & Usage ⚙️

## Overview
This Terraform module centralizes GitHub organization management for **Graphnethealth Limited**. It uses the Terraform GitHub provider (integrations/github) and authenticates using a secure **GitHub App**. The module serves as the single source of truth for creating and securing all repositories, teams, and access control policies.

| Feature | Configuration |
| :--- | :--- |
| **Provider** | `integrations/github` |
| **Authentication** | GitHub App (via Github Secrets for PEM key and OIDC-driven CI/CD) |
| **State Storage** | Azure Blob Storage (using `backend "azurerm"`) |
| **Deployment Gate** | Manual `workflow_dispatch` into a protected `main` environment. |
| **Input Structure** | All configuration uses idiomatic **Map-based variables** (`map(object)`). |

---

## 1. GitHub Organization Terraform Module — Design & Usage

The module automates key infrastructure tasks, adhering to a high standard of security and reliability:

### Module Responsibilities and Best Practices

1.  **Repository Management:** Creates repositories and includes **variable validation** to ensure all repository names adhere to GitHub's rules (`^[a-zA-Z0-9._-]+$`). It ensures `main` and `develop` branches exist.
2.  **Branch Protection Policy:** Applies standardized `github_branch_protection` policies to `main`, `develop`, and user-specified branches.
    * **Default Rules:** Require pull request reviews (minimum 2 approvals), require CODEOWNERS review, and disallow force pushes/branch deletions.
3.  **Teams and Access Control:** manages teams, memberships, and assigns granular access (e.g., `pull`, `push`, `admin`) via `github_team_repository`.
4.  **GitHub Actions Security 🔒:** Enforces **"selected" action permissions** for all managed repos, explicitly **disallows unverified third-party actions** (`third_party_allowed = false`), and applies a centralized whitelist of approved actions (e.g., `Azure/login@v1`).

### Naming and Code Convention

Repository names follow the scheme: `team-service-component`.

| Entity | Examples |
| :--- | :--- |
| **Repository Names** | `platform-terraform`, `backend-svc-alpha`, `docs-public-website` |
| **Team Names** | `platform-automation`, `backend-team`, `security-ops` |

---

## 2. Workflow & CI/CD Process

The deployment pipeline is highly secured, relying on OIDC and manual approval gates.

| Stage | Workflow (`.yml`) | Authentication & Action | Gate / Security |
| :--- | :--- | :--- | :--- |
| **Planning** | `tf-plan.yml` (on PR) | 1. `azure/login` using **OIDC**. 2. Retrieve **PEM key** from Azure Key Vault. 3. `terraform plan -out=tfplan.binary`. | Automatic, but requires **Code Review** of the plan output. |
| **Artifact Storage** | `tf-plan.yml` | Uploads artifact named `tfplan-${{ github.run_id }}`. | Run ID is communicated to reviewers. |
| **Applying** | `tf-apply.yml` (Manual) | **1. Approver required.** 2. Downloads artifact using `plan_run_id` input. 3. `terraform init` uses **OIDC** flags for backend authentication. 4. `terraform apply tfplan.binary`. | Manual `workflow_dispatch`, enforced by **`production` environment approval**. |

---

## 3. Security & Secrets (OIDC & Backend)

The architecture separates static configuration from dynamic, sensitive credentials using OIDC for both provider authentication and state file access.

| Component | Storage/Source | Authentication Method |
| :--- | :--- | :--- |
| **GitHub App PEM Key** | Azure Key Vault | Retrieved in CI using `azure/cli` authenticated via OIDC. |
| **Terraform State** | Azure Blob Storage | **OIDC** via `-backend-config` flags during `terraform init`. |
| **Terraform Provider** | GitHub App Credentials | Injected from environment variables set by the PEM key retrieval step. |

---

## 4. Operational Notes & Troubleshooting ⚠️

1.  **Backend Configuration:** The Azure Blob Storage location is defined statically in the **`backend.tf`** file. Authentication is handled dynamically in the workflow; do **not** use `-backend-config` flags for location details during `terraform init`.
2.  **Repository Name Failure:** If `terraform plan` fails with a custom validation error message, correct the repository name in `variables.tf` to use only alphanumeric characters, hyphens, periods, or underscores.
3.  **OIDC Role:** The Azure AD Service Principal linked to the GitHub OIDC federated credential must have the necessary **Storage Blob Data Contributor** role on the state storage account.
4.  **Provider Version:** Use provider version `integrations/github ~> 6.0` to ensure compatibility with all GitHub API features used by the module.