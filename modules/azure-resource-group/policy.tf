resource "azurerm_storage_management_policy" "datahub_log_data" {
  storage_account_id = azurerm_storage_account.datahub_storageaccount.id

  rule {
    name    = "logblock"
    enabled = true
    filters {
      blob_types   = ["blockBlob"]
      prefix_match = ["${local.datahub_log_name}/"]
    }
    actions {
      base_blob { delete_after_days_since_modification_greater_than = local.log_keep_days }
      snapshot { delete_after_days_since_creation_greater_than = local.log_keep_days }
      version { delete_after_days_since_creation = local.log_keep_days }
    }
  }

  rule {
    name    = "logappend"
    enabled = true
    filters {
      blob_types   = ["appendBlob"]
      prefix_match = ["${local.datahub_log_name}/"]
    }
    actions {
      base_blob { delete_after_days_since_modification_greater_than = local.log_keep_days }
      snapshot { delete_after_days_since_creation_greater_than = local.log_keep_days }
      version { delete_after_days_since_creation = local.log_keep_days }
    }
  }
}

