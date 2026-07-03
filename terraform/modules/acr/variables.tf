variable "resource_group_name" {
  description = "Name of the Azure resource group where the container registry will be created."
  type        = string
}

variable "location" {
  description = "Azure region where the container registry will be deployed."
  type        = string
}

variable "environment" {
  description = "Deployment environment used as part of the registry naming convention."
  type        = string
}
