data "azurerm_subscription" "az_subscription" {
  subscription_id = var.az_subscription_id
}

locals {
  storage_account_name     = lower("${var.resource_prefix}proj${var.project_cd}${var.environment_name}")
  resource_group_location = "${var.az_location}"
}
