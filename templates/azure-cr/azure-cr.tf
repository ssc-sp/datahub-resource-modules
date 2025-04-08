module "azure_cr_module" {
  source     = "github.com/ssc-sp/datahub-resource-modules//modules/azure-cr{{tag}}"
  depends_on = [module.azure_app_service_module]

  resource_group_name        = module.resource_group_module.az_project_rg_name
  key_vault_id               = module.resource_group_module.az_project_kv_id
  key_vault_cmk_id           = module.resource_group_module.az_project_cmk_id
  key_vault_url              = module.resource_group_module.az_project_kv_url
  key_vault_name             = module.resource_group_module.az_project_kv_name
  log_analytics_workspace_id = var.log_analytics_workspace_id
  sp_client_oid              = var.datahub_app_sp_oid
  app_service_oid            = module.azure_app_service_module.app_service_oid

  # optional variables
  environment_name   = var.environment_name
  az_tenant_id       = var.az_tenant_id
  az_subscription_id = var.az_subscription_id
  project_cd         = var.project_cd
  project_tags       = module.resource_group_module.project_tags
}
