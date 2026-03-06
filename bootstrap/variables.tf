variable "subscription_id" {
  type        = string
  description = "The subscription GUID where the resources are to be created."
}

variable "location" {
  type        = string
  description = "The Azure location where resources are to be created. E.g. \"UK South\""
  default     = "UK South"
}

variable "project_acronym" {
  type        = string
  description = "The abbreviated project name."
}

variable "subscription_env" {
  type        = string
  description = "The subscription environment, e.g 'prod' or 'preprod'."
}

variable "vnet_address_space" {
  type        = list(string)
  description = "The address space that has been allocated for the virtual network." 
}

variable "rt_next_hop_ip" {
  type        = string
  description = "The IP address of the virtual appliance via which to route all outbound traffic from the VNet. For services based in UK South, this will normally be \"10.8.0.4\" - the UKS Firewall."
  default     = "10.8.0.4" # CPS Hub South Firewall
}

variable "dns_servers" {
  type        = list(string)
  description = "A list of DNS servers' IPs to use for IP resolution in the VNet."
  default     = ["10.14.136.4", "10.7.136.4"] # CPS Hub DNS Resolvers
}

variable "sa_environments" {
  type        = set(string)
  description = "The names of the environments requiring a terraform backend storage account provisioned. E.g. in a 'preprod' subscription, you may input [\"dev\", \"staging\"]."
}

variable "vmss_sku" {
  type        = string
  description = "The SKU to use for instances in the VMSS."
  default     = "Standard_D2s_v3"
}

variable "ssh_public_key_path" {
  type = string
  description = "The path of a public key from an SSH key-pair to be used for admin access to VMs within the Scale Set. E.g. \"~/.ssh/my_ssh_key.pub\""
}
