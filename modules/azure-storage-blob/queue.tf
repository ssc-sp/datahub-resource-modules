resource "azurerm_storage_queue" "virus_scan_queue" {
  name                 = "virus-scan"
  storage_account_name = azurerm_storage_account.datahub_storageaccount.name
}
