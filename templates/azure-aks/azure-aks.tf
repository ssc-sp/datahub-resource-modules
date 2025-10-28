module "azure_aks" {
  source     = "github.com/ssc-sp/datahub-resource-modules//modules/azure-aks{{tag}}"

  resource_group_name        = module.resource_group_module.az_project_rg_name
  key_vault_name             = module.resource_group_module.az_project_kv_name
  key_vault_id               = module.resource_group_module.az_project_kv_id
  key_vault_cmk_name         = module.resource_group_module.az_project_cmk
  storage_acct_name          = module.azure_storage_blob_module.azure_storage_account_name
  storage_container_name     = module.azure_storage_blob_module.azure_storage_container_name
  storage_blob_endpoint      = module.azure_storage_blob_module.datahub_blob_endpoint
  log_analytics_workspace_id = var.log_analytics_workspace_id
  storage_key_secret_id      = module.azure_storage_blob_module.storage_key_secret_id
  storage_conn_secret_id     = module.azure_storage_blob_module.storage_conn_secret_id
  storage_sas_secret_id      = module.azure_storage_blob_module.storage_sas_secret_id
  container_app_size         = var.container_app_size
  container_app_max_node     = var.container_app_max_node
  container_app_min_node     = var.container_app_min_node
  container_app_profile      = var.container_app_profile
  app_fileshare_name         = var.app_fileshare_name
  container_ingress_port     = var.container_ingress_port

  # optional variables
  az_tenant_id       = var.az_tenant_id
  az_subscription_id = var.az_subscription_id
  project_cd         = var.project_cd

  environment_name = var.environment_name
  az_location      = var.az_location
}

output "azure_aks_status" {
  value = "completed"
}
