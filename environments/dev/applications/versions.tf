terraform {
  required_version = # add Terraform version

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = # add AzureRM provider version
    }
    # add other providers here as required
  }
}

provider "azurerm" {
  features {}
  storage_use_azuread = true
}
