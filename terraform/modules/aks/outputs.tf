output "id" {
  description = "ID of the AKS cluster resource."
  value       = azurerm_kubernetes_cluster.this.id
}

output "name" {
  description = "Name of the AKS cluster."
  value       = azurerm_kubernetes_cluster.this.name
}

output "host" {
  description = "Kubernetes API server endpoint exposed by the AKS cluster kubeconfig."
  value       = azurerm_kubernetes_cluster.this.kube_config[0].host
}

output "kubelet_identity_object_id" {
  description = "Object ID of the kubelet managed identity used by AKS worker nodes."
  value       = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}
