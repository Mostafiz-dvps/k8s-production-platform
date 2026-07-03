output "login_server" {
  description = "Login server hostname for the Azure Container Registry."
  value       = azurerm_container_registry.this.login_server
}

output "registry_id" {
  description = "ID of the Azure Container Registry resource."
  value       = azurerm_container_registry.this.id
}
