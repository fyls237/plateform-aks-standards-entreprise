resource "azurerm_key_vault_key" "this" {
  name         = var.key_name
  key_vault_id = var.key_vault_id
  key_type     = var.key_type
  key_size     = var.key_size
  key_opts     = var.key_opts

  rotation_policy {
    automatic {
      time_before_expiry = var.key_rotation_time_before_expiry
    }

    expire_after         = var.key_expiration
    notify_before_expiry = var.key_notification_before_expiry
  }
}

resource "azurerm_disk_encryption_set" "this" {
  name                      = var.name
  resource_group_name       = var.resource_group_name
  location                  = var.location
  key_vault_key_id          = azurerm_key_vault_key.this.versionless_id
  auto_key_rotation_enabled = true

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "key_vault_crypto_service_encryption_user" {
  scope                            = azurerm_key_vault_key.this.resource_versionless_id
  role_definition_name             = "Key Vault Crypto Service Encryption User"
  principal_id                     = azurerm_disk_encryption_set.this.identity[0].principal_id
  skip_service_principal_aad_check = true

  depends_on = [
    azurerm_disk_encryption_set.this,
  ]
}
