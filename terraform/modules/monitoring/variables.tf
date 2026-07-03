variable "resource_group_name" {
  description = "Name of the Azure resource group where monitoring resources will be created."
  type        = string
}

variable "location" {
  description = "Azure region where the Log Analytics workspace will be deployed."
  type        = string
}

variable "environment" {
  description = "Deployment environment used for naming monitoring resources."
  type        = string
  default     = "shared"
}

variable "aks_cluster_id" {
  description = "ID of the AKS cluster that should send diagnostics to Log Analytics."
  type        = string
}
