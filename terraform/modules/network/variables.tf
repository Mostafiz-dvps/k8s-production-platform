variable "resource_group_name" {
  description = "Name of the Azure resource group where network resources will be created."
  type        = string
}

variable "location" {
  description = "Azure region where the virtual network and subnets will be deployed."
  type        = string
}

variable "environment" {
  description = "Deployment environment used for naming network resources."
  type        = string
}
