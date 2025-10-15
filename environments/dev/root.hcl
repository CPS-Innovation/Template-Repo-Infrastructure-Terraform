remote_state {
  backend      = "azurerm"
  disable_init = tobool(get_env("TERRAGRUNT_DISABLE_INIT", "false"))

  generate = {
    path      = "_backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    key                  = "${path_relative_to_include()}/terraform.tfstate"
    resource_group_name  = # add the name of the RG containing the backend storage account
    storage_account_name = # add the name of the backend storage account
    container_name       = "tfstate"
  }
}
