module "azure_storage_blob_module" {
  source     = "github.com/ssc-sp/datahub-resource-modules//modules/azure-storage-blob{{tag}}"
  depends_on = [module.resource_group_module]

  resource_group_name          = module.resource_group_module.az_project_rg_name
  key_vault_name               = module.resource_group_module.az_project_kv_name
  key_vault_id                 = module.resource_group_module.az_project_kv_id
  key_vault_cmk_name           = module.resource_group_module.az_project_cmk
  automation_acct_principal_id = module.resource_group_module.automation_acct_principal_id
  log_analytics_workspace_id   = var.log_analytics_workspace_id
  enable_defender              = var.enable_defender
  enable_clamav                = var.enable_clamav
  clamav_docker_image          = module.resource_group_module.clamav_docker_image
  sas_docker_image             = module.resource_group_module.sas_docker_image
  container_app_env_id         = module.resource_group_module.container_app_env_id

  # optional variables
  az_tenant_id              = var.az_tenant_id
  az_subscription_id        = var.az_subscription_id
  project_cd                = var.project_cd
  storage_contributor_users = var.storage_contributor_users
  storage_reader_users      = var.storage_reader_users
  storage_size_limit_tb     = var.storage_size_limit_tb
  project_tags              = module.resource_group_module.project_tags

  environment_name = var.environment_name
  az_location      = var.az_location
}

output "azure_storage_account_name" {
  value = module.azure_storage_blob_module.azure_storage_account_name
}

output "azure_storage_container_name" {
  value = module.azure_storage_blob_module.azure_storage_container_name
}

output "azure_storage_blob_status" {
  value = "completed"
}
