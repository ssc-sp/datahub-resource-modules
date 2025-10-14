data "azurerm_client_config" "current" {}

data "azurerm_key_vault_secret" "storage_key_secret" {
  name         = local.secret_name_storage_key
  key_vault_id = var.key_vault_id
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
}
