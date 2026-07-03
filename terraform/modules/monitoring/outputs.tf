output "workspace_id" {
  description = "ID of the Log Analytics workspace receiving AKS diagnostics."
  value       = azurerm_log_analytics_workspace.this.id
}
