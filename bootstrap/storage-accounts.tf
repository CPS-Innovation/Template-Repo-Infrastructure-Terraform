# Create storage accounts to store tfstate files and VMSS boot diagnostics
locals {
  sa_for_each = merge(
    tomap({
      for env in var.sa_environments : env => {
        purpose     = "tfstate"
        environment = "${env}"
      }
    }),
    { vmss = {
      purpose     = "bootdiag"
      environment = var.subscription_env
    } }
  )
}

resource "azurerm_storage_account" "sa" {
  for_each = local.sa_for_each

  name                            = "sa${var.project_acronym}${each.value.purpose}${each.value.environment}"
  resource_group_name             = azurerm_resource_group.devops.name
  location                        = local.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  public_network_access_enabled   = false
  allow_nested_items_to_be_public = false
  local_user_enabled              = false
  allowed_copy_scope              = "AAD"

  network_rules {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  blob_properties {
    delete_retention_policy {
      days                     = 7
      permanent_delete_enabled = false
    }
    versioning_enabled = true
  }

  tags = merge(
    {
      environment = each.value.environment
    },
    local.global_tags
  )
}

resource "azurerm_private_endpoint" "sa" {
  for_each = local.sa_for_each

  name                = "pe-${azurerm_storage_account.sa[each.key].name}"
  location            = local.location
  resource_group_name = azurerm_resource_group.devops.name
  subnet_id           = azurerm_subnet.devops.id

  private_service_connection {
    name                           = azurerm_storage_account.sa[each.key].name
    private_connection_resource_id = azurerm_storage_account.sa[each.key].id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "sa-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.dns.id]
  }

  tags = merge(
    {
      environment = each.value.environment
    },
    local.global_tags
  )
}

# Create storage containers for terraform state files
resource "azurerm_storage_container" "sa" {
  for_each = var.sa_environments

  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.sa[each.value].id
  container_access_type = "private"
}
