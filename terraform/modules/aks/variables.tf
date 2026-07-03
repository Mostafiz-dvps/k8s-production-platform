variable "resource_group_name" {
  description = "Name of the Azure resource group where the AKS cluster will be created."
  type        = string
}

variable "location" {
  description = "Azure region where the AKS cluster will be deployed."
  type        = string
}

variable "cluster_name" {
  description = "Name of the AKS cluster."
  type        = string
}

variable "node_size" {
  description = "Azure VM size for the AKS default node pool."
  type        = string
}

variable "node_count" {
  description = "Number of worker nodes in the AKS default node pool."
  type        = number
}

variable "kubernetes_version" {
  description = "Kubernetes version to use for the AKS control plane and node pool."
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet where the AKS default node pool should be placed."
  type        = string
}
