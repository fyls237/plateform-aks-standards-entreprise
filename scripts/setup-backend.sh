#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# setup-backend.sh
# Creates Azure Storage Account for Terraform remote state
# ---------------------------------------------------------------------------

set -euo pipefail

# Configuration
RESOURCE_GROUP="${TF_STATE_RG:-rg-terraform-state}"
LOCATION="${TF_STATE_LOCATION:-westeurope}"
STORAGE_ACCOUNT="${TF_STATE_SA:-stterraformstate$(openssl rand -hex 4)}"
CONTAINER_NAME="${TF_STATE_CONTAINER:-tfstate}"

echo "============================================"
echo " Terraform State Backend Setup"
echo "============================================"
echo ""
echo " Resource Group:    $RESOURCE_GROUP"
echo " Location:          $LOCATION"
echo " Storage Account:   $STORAGE_ACCOUNT"
echo " Container:         $CONTAINER_NAME"
echo ""

# Check Azure CLI authentication
if ! az account show &>/dev/null; then
    echo "ERROR: Not logged into Azure CLI. Run 'az login' first."
    exit 1
fi

SUBSCRIPTION=$(az account show --query name -o tsv)
echo " Subscription:      $SUBSCRIPTION"
echo ""

read -p "Continue? (y/N) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo "==> Creating resource group..."
az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --tags ManagedBy=terraform Purpose=terraform-state \
    --output none

echo "==> Creating storage account..."
az storage account create \
    --name "$STORAGE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --sku Standard_LRS \
    --kind StorageV2 \
    --https-only true \
    --min-tls-version TLS1_2 \
    --allow-blob-public-access false \
    --tags ManagedBy=terraform Purpose=terraform-state \
    --output none

echo "==> Creating blob container..."
az storage container create \
    --name "$CONTAINER_NAME" \
    --account-name "$STORAGE_ACCOUNT" \
    --auth-mode login \
    --output none

echo "==> Enabling versioning for state recovery..."
az storage account blob-service-properties update \
    --account-name "$STORAGE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --enable-versioning true \
    --output none

echo ""
echo "============================================"
echo " Backend Configuration"
echo "============================================"
echo ""
echo "  resource_group_name  = \"$RESOURCE_GROUP\""
echo "  storage_account_name = \"$STORAGE_ACCOUNT\""
echo "  container_name       = \"$CONTAINER_NAME\""
echo ""
echo " Update backend.tf in each environment with these values."
echo "============================================"
