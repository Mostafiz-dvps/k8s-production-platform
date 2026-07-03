# Azure Kubernetes Service cluster for running the application platform.
resource "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.cluster_name}-dns"
  kubernetes_version  = var.kubernetes_version

  # Default system node pool for cluster control-plane and workload scheduling.
  default_node_pool {
    name           = "system"
    vm_size        = var.node_size
    node_count     = var.node_count
    vnet_subnet_id = var.subnet_id
  }

  # System-assigned managed identity lets Azure manage AKS identity lifecycle.
  identity {
    type = "SystemAssigned"
  }

  # Basic platform identity for kubelet-managed Azure interactions.
  role_based_access_control_enabled = true
}
