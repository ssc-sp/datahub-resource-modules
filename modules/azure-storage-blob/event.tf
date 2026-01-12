resource "azurerm_eventgrid_system_topic" "project_blob_created_system_topic" {
  name                   = "${azurerm_storage_account.datahub_storageaccount.name}blobcreatedtopic"
  location               = local.resource_group_location
  resource_group_name    = var.resource_group_name
  source_arm_resource_id = azurerm_storage_account.datahub_storageaccount.id
  topic_type             = "Microsoft.Storage.StorageAccounts"
}

resource "azurerm_eventgrid_system_topic_event_subscription" "blob_created_subscription" {
  name                  = "blobcreatedsubscription"
  system_topic          = azurerm_eventgrid_system_topic.project_blob_created_system_topic.name
  resource_group_name   = var.resource_group_name
  event_delivery_schema = "EventGridSchema"

  included_event_types = ["Microsoft.Storage.BlobCreated"]

  storage_queue_endpoint {
    storage_account_id = azurerm_storage_account.datahub_storageaccount.id
    queue_name         = azurerm_storage_queue.blob_created_event_queue.name
  }

  subject_filter {
    subject_begins_with = "/blobServices/default/containers/${local.datahub_mount_name}/blobs/${local.upload_folder_name}/"
    case_sensitive      = false
  }

  retry_policy {
    max_delivery_attempts = 5
    event_time_to_live    = 1440
  }
}

# Event Grid subscription for blob metadata/properties updates (virus scan status changes)
# This subscription triggers the BlobVirusScanAclUpdater function when ClamAV updates
# the dh:scanStatus metadata after completing a virus scan
resource "azurerm_eventgrid_system_topic_event_subscription" "blob_metadata_updated_subscription" {
  name                  = "blobmetadataupdatedsubscription"
  system_topic          = azurerm_eventgrid_system_topic.project_blob_created_system_topic.name
  resource_group_name   = var.resource_group_name
  event_delivery_schema = "EventGridSchema"

  # Include both BlobPropertiesUpdated and BlobMetadataUpdated events
  # BlobPropertiesUpdated: Triggered when blob properties or metadata change
  # BlobMetadataUpdated: Triggered specifically when metadata changes
  included_event_types = [
    "Microsoft.Storage.BlobPropertiesUpdated",
    "Microsoft.Storage.BlobMetadataUpdated"
  ]

  azure_function_endpoint {
    function_id                       = var.virus_scan_acl_function_id
    max_events_per_batch              = 1
    preferred_batch_size_in_kilobytes = 64
  }

  subject_filter {
    subject_begins_with = "/blobServices/default/containers/${local.datahub_mount_name}/blobs/${local.upload_folder_name}/"
    case_sensitive      = false
  }

  retry_policy {
    max_delivery_attempts = 5
    event_time_to_live    = 1440
  }

  # Advanced filter to only trigger on relevant blob operations
  # This reduces unnecessary function invocations
  advanced_filter {
    string_begins_with {
      key    = "data.api"
      values = ["PutBlob", "PutBlockList", "CopyBlob", "SetBlobMetadata", "SetBlobProperties"]
    }
  }
}
