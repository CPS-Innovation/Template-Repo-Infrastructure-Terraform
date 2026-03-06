# Create a private dns zone for storage blob private endpoints
resource "azurerm_private_dns_zone" "dns" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.vnet.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns" {
  name                  = "dnszonelink-blob"
  resource_group_name   = azurerm_resource_group.vnet.name
  private_dns_zone_name = azurerm_private_dns_zone.dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}
