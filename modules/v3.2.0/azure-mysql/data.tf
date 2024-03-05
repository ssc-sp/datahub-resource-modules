data "azurerm_client_config" "current" {}

# My public IP: data.http.myip.response_body
data "http" "myip" {
  url = "https://ipecho.net/plain"
}

locals {
  project_tags      = merge(var.common_tags, { "project_cd" : var.project_cd })
  mysql_server_name = "${var.resource_prefix}-portal-mysql-${var.environment_name}"
  mysql_admin_user  = "fsdhadmin"
  mysql_db_name     = "fsdh"
}
