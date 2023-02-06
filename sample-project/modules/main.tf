data "azurerm_client_config" "current" {}

module "resourceGroup" {
  source                = "../../modules/azure-resource-group"
  az_tenant_id          = var.az_tenant
  az_subscription_id    = var.az_subscription
  project_cd            = var.project_cd
  datahub_app_object_id = var.datahub_app_object_id
  environment_name      = var.environment_name
  common_tags           = var.common_tags
}

module "storage" {
  source                    = "../../modules/azure-storage-blob"
  depends_on                = [module.resourceGroup]
  resource_group_name       = module.resourceGroup.az_project_rg_name
  key_vault_id              = module.resourceGroup.az_project_kv_id
  key_vault_cmk_name        = module.resourceGroup.az_project_cmk
  az_tenant_id              = var.az_tenant
  az_subscription_id        = var.az_subscription
  project_cd                = var.project_cd
  environment_name          = var.environment_name
  storage_contributor_users = var.storage_contributor_users
  storage_size_limit_tb     = var.storage_size_limit_tb
  common_tags               = var.common_tags
}

module "databricks" {
  source              = "../../modules/azure-databricks"
  resource_group_name = module.resourceGroup.az_project_rg_name
  key_vault_id        = module.resourceGroup.az_project_kv_id
  key_vault_cmk_id    = module.resourceGroup.az_project_cmk_id
  az_tenant_id        = var.az_tenant
  az_subscription_id  = var.az_subscription
  project_cd          = var.project_cd
  common_tags         = var.common_tags
  admin_users         = var.databricks_admin_users
  az_databricks_sp    = var.az_databricks_sp
  storage_acct_name   = module.storage.storage_acct_name
  run_in_devops       = false
}
