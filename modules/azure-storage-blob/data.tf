data "azurerm_client_config" "current" {}

data "azurerm_subscription" "az_subscription" {
  subscription_id = var.az_subscription_id
}

data "azurerm_monitor_action_group" "datahub_proj_action_group_email" {
  resource_group_name = var.resource_group_name
  name                = "${var.resource_prefix}-proj-actiongroup-${var.project_cd}-${var.environment_name}-email"
}

locals {
  sanitized_prefix         = lower(replace(replace(var.resource_prefix_alphanumeric, "_", ""), "-", ""))
  base_name                = lower("${local.sanitized_prefix}proj${var.project_cd}${var.environment_name}")
  storage_account_name     = local.base_name
  storage_key_secret       = "storage-key"
  storage_sas_secret       = "container-sas"
  storage_conn_secret      = "storage-conn"
  datahub_mount_name       = "datahub"
  datahub_backup_name      = "datahub-backup"
  datahub_log_name         = "datahub-log"
  datahub_temp_name        = "datahub-temp"
  datahub_quarantine       = "datahub-quarantine"
  upload_folder_name       = "upload"
  blob_created_queue       = "blob-created"
  blob_muted_queue         = "blob-event-muted"
  table_infected_file      = "infectedfiles"
  resource_group_location  = var.az_location
  storage_size_limit_bytes = 1024 * 1024 * 1024 * 1024 * var.storage_size_limit_tb
  log_keep_days            = 90
}
