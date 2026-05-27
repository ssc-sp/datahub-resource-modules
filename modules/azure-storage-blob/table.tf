resource "azurerm_storage_table" "datahub_infected_files" {
  name                 = "infectedfiles"
  storage_account_name = azurerm_storage_account.datahub_storageaccount.name
}
