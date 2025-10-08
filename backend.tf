terraform {
  backend "azurerm" {
    # resource_group_name  = "tf-backend-rg"
    # storage_account_name = "tfstate17568"
    # container_name       = "ghtfstate"
    key                  = "github-org.tfstate"
    use_oidc             = true
  }
}
provider "azurerm" {
  features {}
  use_oidc = true
}