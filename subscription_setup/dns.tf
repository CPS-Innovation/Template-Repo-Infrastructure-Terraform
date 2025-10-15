# Associate the VNet with the CPS hub DNS resolvers
resource "azurerm_virtual_network_dns_servers" "dns" {
  virtual_network_id = local.vnet_id
  dns_servers        = ["10.8.0.6", "10.8.0.7"]
}

# Create a private dns zone for storage blob private endpoints
resource "azurerm_private_dns_zone" "dns" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.vnet_rg
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns" {
  name                  = "dnszonelink-blob"
  resource_group_name   = var.vnet_rg
  private_dns_zone_name = azurerm_private_dns_zone.dns.name
  virtual_network_id    = local.vnet_id
}
