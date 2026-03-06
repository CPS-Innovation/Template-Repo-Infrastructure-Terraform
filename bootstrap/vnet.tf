locals {
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

resource "azurerm_resource_group" "vnet" {
  name     = "rg-${var.project_acronym}-connectivity-${var.subscription_env}"
  location = var.location
  tags     = local.sub_scope_tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.project_acronym}-${var.subscription_env}"
  location            = azurerm_resource_group.vnet.location
  resource_group_name = azurerm_resource_group.vnet.name
  address_space       = var.vnet_address_space
  dns_servers         = var.dns_servers
  tags                = local.sub_scope_tags
}

# Create a route table for the subscription
resource "azurerm_route_table" "rt" {
  name                = "rt-${var.project_acronym}-${var.subscription_env}"
  location            = var.location
  resource_group_name = azurerm_resource_group.vnet.name
  route {
    name                   = "default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.rt_next_hop_ip
  }

  tags = local.sub_scope_tags
}

# Create a subnet for devops resources ips
locals {
  vnet_cidr          = var.vnet_address_space[0]
  cidrsubnet_newbits = 28 - tonumber(regex("\\d+$", local.vnet_cidr))
  subnet_cidr        = cidrsubnet(local.vnet_cidr, local.cidrsubnet_newbits, 0)
}

resource "azurerm_subnet" "devops" {
  name                 = "subnet-${var.project_acronym}-devops-${var.subscription_env}"
  resource_group_name  = azurerm_resource_group.vnet.name
  virtual_network_name = azurerm_virtual_network.vnet.name
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
  location = var.location

  tags = local.sub_scope_tags
}
