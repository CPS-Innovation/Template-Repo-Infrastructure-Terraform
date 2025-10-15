# Suggested variables:

variable "project_acronym" {
  type        = string
  description = "The abbreviated project name."
}

variable "environment" {
  type        = string
  description = "The deployment environment."
}

variable "location" {
  type        = string
  description = "Specifies the supported Azure location where the resource exists."
}

variable "vnet_name" {
  type        = string
  description = "The name of the virtual network in which to create the subnets."
}

variable "vnet_rg" {
  type        = string
  description = "The name of the resource group containing the virtual network."
}
