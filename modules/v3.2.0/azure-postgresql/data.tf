data "azurerm_client_config" "current" {}

# My public IP: data.http.myip.response_body
data "http" "myip" {
  url = "https://ipecho.net/plain"
}

locals {
  project_tags     = merge(var.common_tags, { "project_cd" : var.project_cd })
  psql_server_name = lower("${var.resource_prefix}-${var.project_cd}-psql-${var.environment_name}")
  psql_admin_user  = "fsdhadmin"
  psql_db_name     = "fsdh"
}
