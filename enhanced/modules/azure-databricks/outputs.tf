output "azure_databricks_workspace_id" {
  value = azapi_resource.fsdh_databricks.id

}

output "azure_databricks_workspace_name" {
  value = azapi_resource.fsdh_databricks.name
}

output "azure_databricks_workspace_url" {
  value = azapi_resource.fsdh_databricks.output.properties.workspaceUrl
}

output "azure_databricks_managed_rg_id" {
  value = azapi_resource.fsdh_databricks.output.properties.managedResourceGroupId
}

# output "azure_databricks_storage_principal_id" {
#   value = azapi_resource.fsdh_databricks.output.properties.storageAccountIdentity.principalId
# }
