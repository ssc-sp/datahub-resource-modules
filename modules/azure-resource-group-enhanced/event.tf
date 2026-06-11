resource "azurerm_eventgrid_system_topic" "project_blob_created_system_topic" {
  name                   = "${azurerm_storage_account.datahub_storageaccount.name}blobcreatedtopic"
  location               = local.resource_group_location
  resource_group_name    = azurerm_resource_group.az_project_rg.name
  source_arm_resource_id = azurerm_storage_account.datahub_storageaccount.id
  topic_type             = "Microsoft.Storage.StorageAccounts"
}

resource "azurerm_eventgrid_system_topic_event_subscription" "blob_created_subscription" {
  count = var.enable_clamav ? 1 : 0

  name                  = "blobcreatedsubscription"
  system_topic          = azurerm_eventgrid_system_topic.project_blob_created_system_topic.name
  resource_group_name   = azurerm_resource_group.az_project_rg.name
  event_delivery_schema = "EventGridSchema"

  included_event_types = ["Microsoft.Storage.BlobCreated"]

  storage_queue_endpoint {
    storage_account_id = azurerm_storage_account.datahub_storageaccount.id
    queue_name         = azurerm_storage_queue.blob_created_event_queue.name
  }


  advanced_filter {
    string_begins_with {
      key = "subject"
      values = [
        "/blobServices/default/containers/${local.datahub_mount_name}/",
        "/blobServices/default/containers/${local.datahub_stage_name}/"
      ]
    }
  }

  retry_policy {
    max_delivery_attempts = 5
    event_time_to_live    = 1440
  }

  # depends_on = [time_sleep.wait_storage_account_network]
}

resource "time_sleep" "wait_storage_account_network" {
  # depends_on = [azurerm_storage_account_network_rules.datahub_storageaccount_runner_rule]

  create_duration = "120s"
}

