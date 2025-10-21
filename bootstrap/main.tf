# Reference the VNet created by the infra team.
data "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.vnet_rg
}

locals {
  location = data.azurerm_virtual_network.vnet.location
  vnet_id  = data.azurerm_virtual_network.vnet.id
  global_tags = {
    project              = var.project_acronym
    managed_by_terraform = false
  }
  sub_scope_tags = merge(
    {
      environment = var.subscription_env
    },
    local.global_tags
  )
}

# Create a route table for the subscription
resource "azurerm_route_table" "rt" {
  name                = "rt-${var.project_acronym}-${subscription_env}"
  location            = local.location
  resource_group_name = var.vnet_rg

  route {
    name                   = "default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.8.0.4"
  }

  tags = local.sub_scope_tags
}

# Create a subnet for devops resources ips
locals {
  vnet_cidr          = data.azurerm_virtual_network.vnet.address_space[0]
  cidrsubnet_newbits = 28 - tonumber(regex("\\d+$", local.vnet_cidr))
  subnet_cidr        = cidrsubnet(local.vnet_cidr, local.cidrsubnet_newbits, 0)
}

resource "azurerm_subnet" "devops" {
  name                 = "subnet-${var.project_acronym}-devops-${subscription_env}"
  resource_group_name  = var.vnet_rg
  virtual_network_name = var.vnet_name
  address_prefixes     = [local.subnet_cidr]
  service_endpoints    = ["Microsoft.Storage", "Microsoft.KeyVault"]
}

# Associate the subnet with the route table
resource "azurerm_subnet_route_table_association" "devops" {
  subnet_id      = azurerm_subnet.devops.id
  route_table_id = azurerm_route_table.rt.id
}

# Create a resource group for devops resources (storage accounts, VMSS)
resource "azurerm_resource_group" "devops" {
  name     = "rg-${var.project_acronym}-devops-${var.subscription_env}"
  location = local.location

  tags = local.sub_scope_tags
}
