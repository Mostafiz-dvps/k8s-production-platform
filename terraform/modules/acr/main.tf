# Azure Container Registry for storing backend and platform container images.
resource "azurerm_container_registry" "this" {
  name                = replace("${var.environment}platformacr", "-", "")
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = false
}
