data "azurerm_client_config" "current" {}

data "azurerm_subscription" "az_subscription" {
  subscription_id = var.az_subscription_id
}

data "azurerm_user_assigned_identity" "proj_auto_acct_uai" {
  name                = var.automation_account_uai_name
  resource_group_name = var.automation_account_uai_rg
  provider            = azurerm.root-workspace
}

locals {
  resource_group_name       = lower("${var.resource_prefix}_proj_${var.project_cd}_${var.environment_name}_rg")
  databricks_rg_name        = lower("${var.resource_prefix}-dbk-${var.project_cd}-${var.environment_name}-rg")
  resource_group_location   = var.az_location
  kv_name                   = lower("${var.resource_prefix}-proj-${var.project_cd}-${var.environment_name}-kv")
  automation_acct_name      = lower("${var.resource_prefix}-proj-${var.project_cd}-${var.environment_name}-auto")
  cost_runbook_name         = lower("${var.resource_prefix}-proj-${var.project_cd}-${var.environment_name}-cost-stop-runbook")
  cost_check_runbook_name   = lower("${var.resource_prefix}-proj-${var.project_cd}-${var.environment_name}-cost-check-runbook")
  sas_rotate_runbook_name   = lower("${var.resource_prefix}-proj-${var.project_cd}-${var.environment_name}-sas-rotate-runbook")
  cmk_name                  = "project-cmk"
  webhook_expiry_time       = "2033-04-01T00:00:00Z"
  current_fiscal_year_start = contains(["1", "2", "3"], formatdate("M", timestamp())) ? "${formatdate("YYYY", timestamp()) - 1}-04-01T00:00:00Z" : "${formatdate("YYYY", timestamp())}-04-01T00:00:00Z"
  project_tags              = merge(var.common_tags, { "project_cd" : var.project_cd })
  storage_account_name      = lower("${var.resource_prefix}proj${var.project_cd}${var.environment_name}")
}

data "template_file" "az_project_disable_cmk_script" {
  template = file("${path.module}/rg-disable-cmk.ps1")
  vars = {
    key_vault_name  = azurerm_key_vault.az_proj_kv.name
    subscription_id = var.az_subscription_id
    uai_clientid    = data.azurerm_user_assigned_identity.proj_auto_acct_uai.client_id
  }
}

data "template_file" "az_project_cost_check_script" {
  template = file("${path.module}/rg-check-spend.ps1")
  vars = {
    subscription_id = var.az_subscription_id
    key_vault_name  = azurerm_key_vault.az_proj_kv.name
    budget_name     = azurerm_consumption_budget_resource_group.az_project_rg_budget.0.name
    budget_name_dbr = "${local.databricks_rg_name}-budget"
    trigger_percent = 100
    uai_clientid    = data.azurerm_user_assigned_identity.proj_auto_acct_uai.client_id
  }
}

data "template_file" "az_project_rorate_sas_script" {
  template = file("${path.module}/rg-rotate-sas.ps1")
  vars = {
    key_vault_name      = azurerm_key_vault.az_proj_kv.name
    subscription_id     = var.az_subscription_id
    storage_acct_name   = local.storage_account_name
    resource_group_name = local.resource_group_name
    sas_secret_name     = "container-sas"
    container_name      = "datahub"
    uai_clientid        = data.azurerm_user_assigned_identity.proj_auto_acct_uai.client_id
  }
}

resource "null_resource" "current_fiscal_year_start" {
  provisioner "local-exec" {
    interpreter = ["pwsh", "-Command"]
    command     = <<-EOT
      $month = (get-date -UFormat "%m")
      $year = (get-date -UFormat "%Y")
      if ($month -lt 4 ) { $year = $year - 1; }
      Write-Output "$year-04-01T00:00:00Z"
    EOT
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}
