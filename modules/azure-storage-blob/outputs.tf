output "azure_storage_blob_url" {
  value = azurerm_storage_account.datahub_storageaccount.primary_blob_endpoint
}