module "azure_app_service_module" {
  source     = "github.com/ssc-sp/datahub-resource-modules//modules/{{version}}/azure-app-service{{branch}}"
  depends_on = [module.azure_storage_blob_module]

  resource_group_name = module.resource_group_module.az_project_rg_name
  key_vault_id        = module.resource_group_module.az_project_kv_id
  key_vault_cmk_id    = module.resource_group_module.az_project_cmk_id
  key_vault_url       = module.resource_group_module.az_project_kv_url
  key_vault_name      = module.resource_group_module.az_project_kv_name
  storage_acct_name   = module.azure_storage_blob_module.azure_storage_account_name
  storage_acct_key    = module.azure_storage_blob_module.azure_storage_account_key

  # optional variables
  az_tenant_id       = var.az_tenant_id
  az_subscription_id = var.az_subscription_id
  project_cd         = var.project_cd
  common_tags        = var.common_tags
}

output "azure_app_service_module_status" {
  value = "completed"
}

output "azure_app_service_id" {
  value = module.azure_app_service_module.app_service_id
}

output "azure_app_service_hostname" {
  value = module.azure_app_service_module.proj_app_azure_domain
}
