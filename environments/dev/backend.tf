# ---------------------------------------------------------------------------
# Remote State Backend
# Run scripts/setup-backend.sh to create the storage account before init.
# ---------------------------------------------------------------------------

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstateeb0206c9"
    container_name       = "tfstate"
    key                  = "dev/platform-aks.tfstate"
  }
}
