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

output "azure_storage_account_id" {
  value = azurerm_storage_account.datahub_storageaccount.id
}

output "azure_storage_account_key" {
  value     = azurerm_storage_account.datahub_storageaccount.primary_access_key
  sensitive = true
}

output "azure_storage_container_name" {
  value = azurerm_storage_container.datahub_default.name
}

output "azure_temp_fileshare_name" {
  value = azurerm_container_app_environment_storage.datahub_temp.name
}

output "storage_key_secret_id" {
  value = azurerm_key_vault_secret.storage_key_secret.id
}

output "storage_conn_secret_id" {
  value = azurerm_key_vault_secret.storage_conn_secret.id
}

output "storage_sas_secret_id" {
  value = azurerm_key_vault_secret.storage_sas_secret.id
}

