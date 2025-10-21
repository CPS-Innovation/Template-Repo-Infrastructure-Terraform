variable "subscription_id" {
  type        = string
  description = "The subscription guid where the resources are to be created."
}

variable "project_acronym" {
  type        = string
  description = "The abbreviated project name."
}

variable "subscription_env" {
  type        = string
  description = "The subscription environment, e.g 'prod' or 'preprod'."
}

variable "vnet_name" {
  type        = string
  description = "The name of the virtual network created for the project."
}

variable "vnet_rg" {
  type        = string
  description = "The name of the resource group containing the virtual network."
}

variable "sa_environments" {
  type        = set(string)
  description = "The names of the environments requiring a terraform backend storage account provisioned. E.g. in a 'preprod' subscription, you may input [\"dev\", \"staging\"]."
}

variable "ssh_public_key_path" {
  type = string
  description = "The path of a public key from an SSH key-pair to be used for admin access to VMs within the Scale Set. E.g. \"~/.ssh/my_ssh_key.pub\""
}
