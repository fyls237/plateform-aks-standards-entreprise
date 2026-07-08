# ---------------------------------------------------------------------------
# Private DNS Module — Main
# Private DNS Zones and Virtual Network Links
# ---------------------------------------------------------------------------

resource "azurerm_private_dns_zone" "private_dns_zone" {
  for_each = var.dns_zones

  name                = each.key
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Flatten vnet_links across all zones for a single for_each
locals {
  vnet_links = flatten([
    for zone_key, zone in var.dns_zones : [
      for link in zone.vnet_links : {
        key                  = "${zone_key}/${link.name}"
        zone_key             = zone_key
        name                 = link.name
        virtual_network_id   = link.virtual_network_id
        registration_enabled = link.registration_enabled
      }
    ]
  ])

  vnet_links_map = { for link in local.vnet_links : link.key => link }
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_zone_virtual_network_link" {
  for_each = local.vnet_links_map

  name                  = each.value.name
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone[each.value.zone_key].name
  virtual_network_id    = each.value.virtual_network_id
  registration_enabled  = each.value.registration_enabled

  tags = var.tags
}
