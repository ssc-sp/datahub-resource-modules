
resource "azurerm_storage_blob" "datahub_sample_blob" {
  name                   = "fsdh-sample.csv"
  storage_account_name   = azurerm_storage_account.datahub_storageaccount.name
  storage_container_name = azurerm_storage_container.datahub_default.name
  type                   = "Block"
  source                 = "${path.module}/fsdh-sample.csv"
}
