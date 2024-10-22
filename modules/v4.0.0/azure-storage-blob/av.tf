resource "azurerm_security_center_storage_defender" "datahub_storageaccount_av" {
  storage_account_id = azurerm_storage_account.datahub_storageaccount.id

  override_subscription_settings_enabled      = true  # Optional
  malware_scanning_on_upload_enabled          = false # Disable for unclassified
  malware_scanning_on_upload_cap_gb_per_month = -1
}
