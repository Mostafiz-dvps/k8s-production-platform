# Virtual network shared by AKS and future private platform dependencies.
resource "azurerm_virtual_network" "this" {
  name                = "${var.environment}-platform-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/16"]
}

# Subnet dedicated to AKS nodes and node-pool level networking.
resource "azurerm_subnet" "aks" {
  name                 = "${var.environment}-aks-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Reserved subnet for a future private database endpoint or other private services.
resource "azurerm_subnet" "database_private_endpoint" {
  name                 = "${var.environment}-db-private-endpoint-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.2.0/24"]

  private_endpoint_network_policies = "Disabled"
}
