data "azurerm_client_config" "current" {}

data "azurerm_key_vault_secret" "storage_key_secret" {
  name         = local.secret_name_storage_key
  key_vault_id = var.key_vault_id
}

locals {
  base_name               = lower("${var.resource_prefix}proj${var.project_cd}${var.environment_name}")
  datahub_app_fileshare   = var.app_fileshare_name
  sample_volume           = "sample-file"
  secret_name_storage_key = "storage-key"
}
