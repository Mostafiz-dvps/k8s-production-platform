# Root Terraform composition for the Azure AKS platform.
# This file wires together only local custom modules under ./modules.

# Resource group that will contain the AKS platform resources for this environment.
resource "azurerm_resource_group" "platform" {
  name     = "${var.environment}-${var.cluster_name}-rg"
  location = var.location
}

# Network module creates the shared virtual network and subnets used by AKS
# and future private platform services such as the database private endpoint.
module "network" {
  source = "./modules/network"

  resource_group_name = azurerm_resource_group.platform.name
  location            = azurerm_resource_group.platform.location
  environment         = var.environment
}

# AKS module creates the Kubernetes cluster and places the default node pool
# into the dedicated AKS subnet provisioned by the network module.
module "aks" {
  source = "./modules/aks"

  resource_group_name = azurerm_resource_group.platform.name
  location            = azurerm_resource_group.platform.location
  cluster_name        = var.cluster_name
  node_size           = var.node_size
  node_count          = var.node_count
  kubernetes_version  = var.kubernetes_version
  subnet_id           = module.network.aks_subnet_id
}

# ACR module creates a private image registry for backend and supporting images.
module "acr" {
  source = "./modules/acr"

  resource_group_name = azurerm_resource_group.platform.name
  location            = azurerm_resource_group.platform.location
  environment         = var.environment
}

# Monitoring module provisions Log Analytics and attaches AKS diagnostic settings
# so cluster platform logs and metrics are centralized.
module "monitoring" {
  source = "./modules/monitoring"

  resource_group_name = azurerm_resource_group.platform.name
  location            = azurerm_resource_group.platform.location
  aks_cluster_id      = module.aks.id
}
