locals {
  vnet_id = var.vnet_name == null ? azurerm_virtual_network.vnet[0].id : data.azurerm_virtual_network.vnet[0].id
}

# If using a pre-existing VNet, associate it with the CPS hub DNS resolvers:
resource "azurerm_virtual_network_dns_servers" "dns" {
  count              = var.vnet_name == null ? 0 : 1
  virtual_network_id = local.vnet_id
  dns_servers        = ["10.14.136.4", "10.7.136.4"]
}

# Create a private dns zone for storage blob private endpoints:
resource "azurerm_private_dns_zone" "dns" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = local.vnet_rg
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns" {
  name                  = "dnszonelink-blob"
  resource_group_name   = local.vnet_rg
  private_dns_zone_name = azurerm_private_dns_zone.dns.name
  virtual_network_id    = local.vnet_id
}
