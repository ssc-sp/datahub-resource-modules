data "azurerm_client_config" "current" {}

data "azurerm_subscription" "az_subscription" {
  subscription_id = var.az_subscription_id
}

data "azurerm_storage_account" "datahub_storageaccount" {
  name                = var.storage_acct_name
  resource_group_name = var.resource_group_name
}

data "azurerm_storage_account_blob_container_sas" "datahub_app_log_sas" {
  connection_string = data.azurerm_storage_account.datahub_storageaccount.primary_connection_string
  container_name    = local.datahub_log_name
  https_only        = true

  start  = local.sas_start_now
  expiry = local.sas_expiry_3m

  permissions {
    read   = true
    add    = true
    create = true
    write  = true
    delete = true
    list   = true
  }
}

data "azurerm_storage_account_blob_container_sas" "datahub_backup_sas" {
  connection_string = data.azurerm_storage_account.datahub_storageaccount.primary_connection_string
  container_name    = local.datahub_backup_name
  https_only        = true

  start  = local.sas_start_now
  expiry = local.sas_expiry_3m

  permissions {
    read   = true
    add    = true
    create = true
    write  = true
    delete = true
    list   = true
  }
}

locals {
  app_service_plan_name   = lower("${var.resource_prefix}-proj-${var.project_cd}-app-plan-${var.environment_name}")
  app_service_name        = lower("${var.resource_prefix}-proj-${var.project_cd}-webapp-${var.environment_name}")
  resource_group_location = "canadacentral"
  storage_key_secret      = "storage-key"
  storage_sas_secret      = "container-sas"
  storage_acct_mount      = "datahub"
  datahub_backup_name     = "datahub-backup"
  datahub_log_name        = "datahub-log"
  root_passwd_secret      = "root-passwd"
  project_tags            = merge(var.common_tags, { "project_cd" : var.project_cd })
  dns_record_name         = lower("${var.project_cd}-app")
  sas_start_now           = formatdate("YYYY-MM-DD", timeadd(timestamp(), "-24h"))
  sas_expiry_3m           = formatdate("YYYY-MM-DD", timeadd(timestamp(), "2184h"))
}
