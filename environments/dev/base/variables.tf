# Suggested variables:

variable "subscription_env" {
  type        = string
  description = "The subscription environment, e.g 'prod' or 'preprod'."
}

variable "project_acronym" {
  type        = string
  description = "The abbreviated project name."
}

variable "vnet_name" {
  type        = string
  description = "The name of the virtual network in which to create the subnets."
}

variable "vnet_rg" {
  type        = string
  description = "The name of the resource group containing the virtual network."
}
