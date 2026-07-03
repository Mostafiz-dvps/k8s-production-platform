variable "environment" {
  description = "Deployment environment name. Allowed values are dev, staging, or production."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "environment must be one of: dev, staging, production."
  }
}

variable "location" {
  description = "Azure region where resources will be deployed."
  type        = string
  default     = "eastus"
}

variable "cluster_name" {
  description = "Name to assign to the AKS cluster."
  type        = string
}

variable "node_size" {
  description = "Azure VM size for the AKS worker nodes."
  type        = string
  default     = "Standard_D2s_v3"
}

variable "node_count" {
  description = "Initial number of AKS worker nodes to provision."
  type        = number
  default     = 2
}

variable "kubernetes_version" {
  description = "Kubernetes version to deploy for the AKS cluster."
  type        = string
  default     = "1.29"
}
