# ---------------------------------------------------------------------------
# Private Endpoint Submodule — Main
#
# Internal, reusable sub-module factoring out the private_endpoint +
# private_dns_zone_group pattern shared by modules/acr, modules/keyvault,
# and future data-plane modules (storage, cosmosdb, ...).
#
# NOT meant to be used standalone outside this repository: it intentionally
# has no versions.tf pin of its own and inherits the provider configuration
# of the calling root module.
# ---------------------------------------------------------------------------

resource "azurerm_private_endpoint" "private_endpoint" {
  count = var.enabled ? 1 : 0

  name                = "${var.name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.name}-psc"
    private_connection_resource_id = var.private_connection_resource_id
    is_manual_connection           = var.is_manual_connection
    subresource_names              = var.subresource_names
  }

  dynamic "private_dns_zone_group" {
    for_each = length(var.private_dns_zone_ids) > 0 ? [1] : []

    content {
      name                 = var.private_dns_zone_group_name
      private_dns_zone_ids = var.private_dns_zone_ids
    }
  }

  tags = var.tags
}
