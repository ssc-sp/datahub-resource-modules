output "azure_databricks_workspace_id" {
  value = azurerm_databricks_workspace.datahub_databricks_workspace.id
}

output "azure_databricks_workspace_name" {
  value = azurerm_databricks_workspace.datahub_databricks_workspace.name
}

output "azure_databricks_workspace_url" {
  value = azurerm_databricks_workspace.datahub_databricks_workspace.workspace_url
}

output "azure_databricks_managed_rg_name" {
  value = azurerm_databricks_workspace.datahub_databricks_workspace.managed_resource_group_name
}

output "azure_databricks_managed_rg_id" {
  value = azurerm_databricks_workspace.datahub_databricks_workspace.managed_resource_group_id
}

output "azure_databricks_storage_principal_id" {
  value = azurerm_databricks_workspace.datahub_databricks_workspace.storage_account_identity[0].principal_id
}
