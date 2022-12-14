output "azure_databricks_workspace_id" {
  value = azurerm_databricks_workspace.datahub_databricks_workspace.id
}

output "azure_databricks_workspace_name" {
  value = azurerm_databricks_workspace.datahub_databricks_workspace.name
}

output "azure_databricks_workspace_url" {
  value = azurerm_databricks_workspace.datahub_databricks_workspace.workspace_url
}