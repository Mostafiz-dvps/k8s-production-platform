output "aks_subnet_id" {
  description = "ID of the subnet used by the AKS cluster node pool."
  value       = azurerm_subnet.aks.id
}

output "vnet_id" {
  description = "ID of the shared virtual network."
  value       = azurerm_virtual_network.this.id
}
