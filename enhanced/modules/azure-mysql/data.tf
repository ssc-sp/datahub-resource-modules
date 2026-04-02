data "azurerm_client_config" "current" {}

# My public IP: data.http.myip.response_body
data "http" "myip" {
  url = "https://checkip.amazonaws.com"
}

locals {
  mysql_server_name = lower("${var.resource_prefix}-${var.project_cd}-mysql-${var.environment_name}")
  mysql_admin_user  = "fsdhadmin"
  mysql_db_name     = "fsdh"
}
