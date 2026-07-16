data "azurerm_client_config" "current" {}

data "azurerm_subscription" "az_subscription" {
  subscription_id = var.az_subscription_id
}

data "http" "myip" {
  url = "https://checkip.amazonaws.com"
}

data "azurerm_user_assigned_identity" "proj_auto_acct_uai" {
  name                = var.automation_account_uai_name
  resource_group_name = var.automation_account_uai_rg
  provider            = azurerm.root-workspace
}

resource "time_static" "proj_first_created" {}

locals {
  resource_group_name     = lower("${var.resource_prefix}_proj_${var.project_cd}_${var.environment_name}_rg")
  databricks_rg_name      = lower("${var.resource_prefix}-dbk-${var.project_cd}-${var.environment_name}-rg")
  resource_group_location = var.az_location
  kv_name                 = lower("${var.resource_prefix}-proj-${var.project_cd}-${var.environment_name}-kv")
  automation_acct_name    = lower("${var.resource_prefix}-proj-${var.project_cd}-${var.environment_name}-auto")
  cost_runbook_name       = lower("${var.resource_prefix}-proj-${var.project_cd}-${var.environment_name}-cost-stop-runbook")
  cost_check_runbook_name = lower("${var.resource_prefix}-proj-${var.project_cd}-${var.environment_name}-cost-check-runbook")
  sas_rotate_runbook_name = lower("${var.resource_prefix}-proj-${var.project_cd}-${var.environment_name}-sas-rotate-runbook")
  service_bus_name        = var.service_bus_name != "" ? var.service_bus_name : "${lower(replace("${var.resource_prefix}", "/[^a-zA-Z\\d]/", ""))}-sbus-${var.environment_name}"

  cmk_name                  = "project-cmk"
  webhook_expiry_time       = "2033-04-01T00:00:00Z"
  current_fiscal_year_start = contains(["1", "2", "3"], formatdate("M", timestamp())) ? "${formatdate("YYYY", timestamp()) - 1}-04-01T00:00:00Z" : "${formatdate("YYYY", timestamp())}-04-01T00:00:00Z"
  project_tags              = merge(var.common_tags, { "project_cd" : var.project_cd, "SSC_CBRID" : var.ssc_cbrid, "created_date" : formatdate("YYYY-MM-DD", time_static.proj_first_created.rfc3339) })
  base_name                 = lower("${var.resource_prefix}proj${var.project_cd}${var.environment_name}")
  storage_account_name      = local.base_name
  acr_name                  = lower(replace(replace(lower("${var.resource_prefix}-proj-${var.project_cd}-acr-${var.environment_name}"), "_", ""), "-", ""))
  logicapp_name             = lower(replace(replace(lower("${var.resource_prefix}-proj-${var.project_cd}-logicapp-${var.environment_name}"), "_", ""), "-", ""))
  acr_image_clamav          = "blobavscan:latest"
  acr_image_proj_cost       = "projcost:latest"
  acr_image_proj_sas        = "projsas:latest"

  sanitized_prefix          = lower(replace(replace(var.resource_prefix_alphanumeric, "_", ""), "-", ""))
  storage_key_secret        = "storage-key"
  storage_sas_secret        = "container-sas"
  storage_conn_secret       = "storage-conn"
  datahub_mount_name        = "datahub"
  datahub_catalog_container = "datahub-catalog"
  datahub_backup_name       = "datahub-backup"
  datahub_stage_name        = "datahub-stage"
  datahub_log_name          = "datahub-log"
  datahub_shared_name       = "shared"
  datahub_upload_name       = "external-uploads"
  datahub_users_name        = "users"
  datahub_temp_name         = "datahub-temp"
  datahub_quarantine        = "datahub-quarantine"
  blob_created_queue        = "blob-created"
  blob_muted_queue          = "blob-event-muted"
  clamav_result_queue       = "clamav-scan-result"
  storage_size_limit_bytes  = 1024 * 1024 * 1024 * 1024 * var.storage_size_limit_tb
  log_keep_days             = 90
}

resource "null_resource" "current_fiscal_year_start" {
  provisioner "local-exec" {
    interpreter = ["pwsh", "-Command"]
    command     = <<-EOT
      $month = (get-date -UFormat "%m")
      $year = (get-date -UFormat "%Y")
      if ($month -lt 4 ) { $year = $year - 1; }
      Write-Output "$year-04-01T00:00:00Z"
    EOT
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}
