data "azurerm_client_config" "current" {}

locals {
  base_name = lower("${var.resource_prefix}proj${var.project_cd}${var.environment_name}")
}
