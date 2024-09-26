module "azure_databricks_module" {
  source = "github.com/ssc-sp/datahub-resource-modules//modules/{{version}}/azure-databricks{{branch}}"

  resource_group_name        = module.resource_group_module.az_project_rg_name
  key_vault_id               = module.resource_group_module.az_project_kv_id
  key_vault_cmk_id           = module.resource_group_module.az_project_cmk_id
  key_vault_url              = module.resource_group_module.az_project_kv_url
  storage_acct_name          = module.azure_storage_blob_module.storage_acct_name
  budget_amount              = var.budget_amount
  log_analytics_workspace_id = var.log_analytics_workspace_id

  # optional variables
  az_tenant_id       = var.az_tenant_id
  az_subscription_id = var.az_subscription_id
  project_cd         = var.project_cd

  environment_name           = var.environment_name
  environment_classification = var.environment_classification
  resource_prefix            = var.resource_prefix

  common_tags = var.common_tags

  admin_users         = var.databricks_admin_users
  project_lead_users  = var.databricks_project_lead_users
  project_users       = var.databricks_project_users
  project_guest_users = var.databricks_project_guests

  azure_databricks_enterprise_oid = var.azure_databricks_enterprise_oid
  run_in_devops                   = false
  log_workspace_id                = var.log_workspace_id
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
