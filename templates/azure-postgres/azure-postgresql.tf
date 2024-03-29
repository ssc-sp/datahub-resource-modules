module "azure_postgresql_module" {
  source = "github.com/ssc-sp/datahub-resource-modules//modules/{{version}}/azure-postgresql{{branch}}"

  resource_group_name = module.resource_group_module.az_project_rg_name
  key_vault_id        = module.resource_group_module.az_project_kv_id
  key_vault_cmk_id    = module.resource_group_module.az_project_cmk_id
  key_vault_url       = module.resource_group_module.az_project_kv_url
  key_vault_name      = module.resource_group_module.az_project_kv_name

  # optional variables
  az_tenant_id       = var.az_tenant_id
  az_subscription_id = var.az_subscription_id
  project_cd         = var.project_cd
  common_tags        = var.common_tags
  environment_name   = var.environment_name

  # allow_source_ip_list = module.azure_app_service_module.proj_app_outbound_ip
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

output "azure_postgresql_server_name" {
  value = module.azure_postgresql_module.psql_name
}

output "azure_postgresql_db_name" {
  value = module.azure_postgresql_module.psql_db_name_project
}

output "azure_postgresql_secret_name_admin" {
  value = module.azure_postgresql_module.secret_name_admin
}

output "azure_postgresql_secret_name_password" {
  value = module.azure_postgresql_module.secret_name_password
}
