output "storage_acct_name" {
  value = azurerm_storage_account.datahub_storageaccount.name
}

output "datahub_blob_container" {
  value = azurerm_storage_container.datahub_default.name
}
