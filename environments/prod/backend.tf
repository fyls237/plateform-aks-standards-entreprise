terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstateeb0206c9"
    container_name       = "tfstate"
    key                  = "prod/platform-aks.tfstate"
  }
}
