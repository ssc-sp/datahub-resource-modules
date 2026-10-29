module "azure_container_app_module" {
  source     = "github.com/ssc-sp/datahub-resource-modules//modules/azure-container-app{{tag}}"
  depends_on = [module.resource_group_module]

  resource_group_name        = module.resource_group_module.az_project_rg_name
  key_vault_name             = module.resource_group_module.az_project_kv_name
  key_vault_id               = module.resource_group_module.az_project_kv_id
  key_vault_cmk_name         = module.resource_group_module.az_project_cmk
  storage_acct_name          = module.resource_group_module.azure_storage_account_name
  storage_acct_key           = module.resource_group_module.azure_storage_account_key
  log_analytics_workspace_id = local.log_analytics_workspace_id

  # optional variables
  az_tenant_id       = local.az_tenant_id
  az_subscription_id = var.az_subscription_id
  project_cd         = var.project_cd

  environment_name = local.environment_name
  az_location      = local.az_location
}

output "azure_container_app_status" {
  value = "completed"
}
