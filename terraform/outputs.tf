output "cluster_name" {
  description = "Name of the AKS cluster."
  value       = module.aks.name
}

output "cluster_endpoint" {
  description = "Kubernetes API server endpoint for the AKS cluster."
  value       = module.aks.host
}

output "acr_login_server" {
  description = "Login server hostname for the Azure Container Registry."
  value       = module.acr.login_server
}

output "vnet_id" {
  description = "ID of the virtual network used by the AKS cluster."
  value       = module.network.vnet_id
}
