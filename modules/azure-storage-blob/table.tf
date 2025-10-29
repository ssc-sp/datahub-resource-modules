resource "azurerm_storage_table" "datahub_table_quarantine" {
  name                 = local.table_infected_file
  storage_account_name = azurerm_storage_account.datahub_storageaccount.name
}