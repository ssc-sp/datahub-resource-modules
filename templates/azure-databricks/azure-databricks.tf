module "azure_databricks_module" {
  source = "github.com/ssc-sp/datahub-resource-modules/modules/azure-databricks"

  resource_group_name = module.resource_group_module.az_project_rg_name
  key_vault_id        = module.resource_group_module.az_project_kv_id
  key_vault_cmk_id    = module.resource_group_module.az_project_cmk_id
  storage_acct_name   = module.azure_storage_blob_module.storage_acct_name

  # optional variables
  az_tenant_id       = var.az_tenant_id
  az_subscription_id = var.az_subscription_id
  project_cd         = var.project_cd

  environment_name           = var.environment_name
  environment_classification = var.environment_classification
  resource_prefix            = var.resource_prefix

  common_tags = var.common_tags
  admin_users = var.databricks_admin_users

  az_databricks_sp = var.az_databricks_sp
  run_in_devops    = false

}

output "azure_databricks_module_status" {
  value = "completed"
}

output "azure_databricks_workspace_id" {
  value = module.azure_databricks_module.azure_databricks_workspace_id
}

output "azure_databricks_workspace_url" {
  value = module.azure_databricks_module.azure_databricks_workspace_url
}

output "azure_databricks_workspace_name" {
  value = module.azure_databricks_module.azure_databricks_workspace_name
}
