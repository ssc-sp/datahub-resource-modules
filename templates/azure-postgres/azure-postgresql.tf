module "azure_postgresql_module" {
  source     = "github.com/ssc-sp/datahub-resource-modules//modules/{{version}}/azure-postgresql{{branch}}"
  depends_on = [module.azure_storage_blob_module]

  resource_group_name = module.resource_group_module.az_project_rg_name
  key_vault_id        = module.resource_group_module.az_project_kv_id
  key_vault_cmk_id    = module.resource_group_module.az_project_cmk_id
  key_vault_url       = module.resource_group_module.az_project_kv_url
  key_vault_name      = module.resource_group_module.az_project_kv_name
  storage_acct_name   = module.azure_storage_blob_module.azure_storage_account_name

  # optional variables
  az_tenant_id       = var.az_tenant_id
  az_subscription_id = var.az_subscription_id
  project_cd         = var.project_cd
  common_tags        = var.common_tags

  allow_source_ip_list = module.azure_app_service_module.proj_app_outbound_ip
}

output "azure_psql_module_status" {
  value = "completed"
}

output "azure_postgresql_dns" {
  value = module.azure_postgresql_module.psql_dns
}

output "azure_postgresql_id" {
  value = module.azure_postgresql_module.psql_id
}

output "azure_postgresql_name" {
  value = module.azure_postgresql_module.psql_name
}

output "azure_postgresql_db_name" {
  value = "fsdn"
}
