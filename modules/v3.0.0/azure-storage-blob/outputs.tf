output "storage_acct_name" {
  value      = azurerm_storage_account.datahub_storageaccount.name
  depends_on = [azurerm_role_assignment.proj_storage_creator_role]
}

output "datahub_blob_container" {
  value = azurerm_storage_container.datahub_default.name
}

output "azure_storage_account_name" {
  value = azurerm_storage_account.datahub_storageaccount.name
}

output "azure_storage_account_key" {
  value     = azurerm_storage_account.datahub_storageaccount.primary_access_key
  sensitive = true
}

output "azure_storage_container_name" {
  value = azurerm_storage_container.datahub_default.name
}
