data "azurerm_client_config" "current" {}

locals {
  batch_acct_name         = replace(lower("${var.resource_prefix}-proj-${var.project_cd}-batch-${var.environment_name}"), "-", "")
  batch_pool_name         = "fsdh-pool-01"
  batch_pool_display_name = "FSDH Default Pool 01"
  resource_group_location = "canadacentral"
  project_tags            = merge(var.common_tags, { "project_cd" : var.project_cd, "env" : var.environment_name })
}
