data "azurerm_client_config" "current" {}

data "azurerm_key_vault_secret" "storage_key_secret" {
  name         = local.secret_name_storage_key
  key_vault_id = var.key_vault_id
}

data "azurerm_resource_group" "az_project_rg" {
  name = var.resource_group_name
}

resource "random_password" "postgres_password" {
  length  = 16
  special = false
}

resource "random_password" "app_user_password" {
  length  = 16
  special = false
}

resource "random_password" "aca_psql_password" {
  length           = 20
  min_lower        = 5
  min_upper        = 5
  min_numeric      = 5
  special          = true
  override_special = "_%@"
}

locals {
  base_name                = lower("${var.resource_prefix}proj${var.project_cd}${var.environment_name}")
  datahub_app_fileshare    = var.app_fileshare_name
  sample_volume            = "sample-file"
  app_volume               = "app"
  secret_name_storage_key  = "storage-key"
  secret_name_storage_conn = "storage-conn"
  secret_name_storage_sas  = "container-sas"
  aks_ssh_key_name         = "${var.resource_prefix}${var.environment_name}"
  aks_cluster_name         = "${var.resource_prefix}${var.environment_name}-aks-cluster"
  aks_admin_name           = "${var.resource_prefix}admin"
}
