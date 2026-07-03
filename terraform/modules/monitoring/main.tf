# Log Analytics workspace used as the central destination for AKS diagnostics.
resource "azurerm_log_analytics_workspace" "this" {
  name                = "${var.environment}-aks-logs"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Diagnostic setting attaches AKS platform logs and metrics to Log Analytics.
resource "azurerm_monitor_diagnostic_setting" "aks" {
  name                       = "${var.environment}-aks-diagnostics"
  target_resource_id         = var.aks_cluster_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  enabled_log {
    category = "kube-apiserver"
  }

  enabled_log {
    category = "kube-controller-manager"
  }

  enabled_log {
    category = "kube-scheduler"
  }

  enabled_log {
    category = "cluster-autoscaler"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
