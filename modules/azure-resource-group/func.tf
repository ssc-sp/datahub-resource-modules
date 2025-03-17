resource "azurerm_service_plan" "az_proj_consumption_plan" {
  name                = local.funcapp_plan
  location            = azurerm_resource_group.az_project_rg.location
  resource_group_name = azurerm_resource_group.az_project_rg.name
  sku_name            = "FC1"
  os_type             = "Windows"
}

resource "azurerm_windows_function_app" "az_proj_func" {
  name                       = local.funcapp_name
  location                   = azurerm_resource_group.az_project_rg.location
  resource_group_name        = azurerm_resource_group.az_project_rg.name
  service_plan_id            = azurerm_service_plan.az_proj_consumption_plan.id
  storage_account_name       = azurerm_storage_account.datahub_seed_storageaccount.name
  storage_account_access_key = azurerm_storage_account.datahub_seed_storageaccount.primary_access_key
  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.proj_auto_acct_uai.id]
  }

  functions_extension_version = "~4"

  site_config {
    always_on         = false
    use_32_bit_worker = false
    application_stack { powershell_core_version = "7.4" }
    cors {
      allowed_origins = [
        "https://portal.azure.com"
      ]
      support_credentials = true
    }
  }

  app_settings = {
    "ApplicationInsightsAgent_EXTENSION_VERSION"      = "~3"
    "XDT_MicrosoftApplicationInsights_Mode"           = "recommended"
    "InstrumentationEngine_EXTENSION_VERSION"         = "~1"
    "XDT_MicrosoftApplicationInsights_BaseExtensions" = "~1"
    "FUNCTIONS_WORKER_RUNTIME"                        = "powershell"
    "FUNCTIONS_WORKER_RUNTIME_VERSION"                = "7.4"
    "APPLICATIONINSIGHTS_CONNECTION_STRING"           = azurerm_application_insights.az_proj_appinsight.connection_string
  }

  tags       = local.project_tags
  depends_on = [azurerm_role_assignment.kv_role_function_py_uai]
  lifecycle {}
}

resource "azurerm_key_vault_access_policy" "kv_func_policy" {
  key_vault_id = azurerm_key_vault.az_proj_kv.id
  tenant_id    = var.az_tenant_id
  object_id    = azurerm_windows_function_app.az_proj_func.identity.0.principal_id

  secret_permissions = ["Get"]
}

resource "azurerm_role_assignment" "kv_role_function_py_uai" {
  scope                = azurerm_key_vault.az_proj_kv.id
  principal_id         = data.azurerm_user_assigned_identity.proj_auto_acct_uai.principal_id
  role_definition_name = "Key Vault Secrets User"
}

resource "null_resource" "func_source_changed" {
  triggers = { source_hash = local.func_source_hash }
}
resource "archive_file" "func_app_zip" {
  type        = "zip"
  source_dir  = local.func_source_dir
  output_path = "${path.module}/output/func-app.zip"

  lifecycle {
    replace_triggered_by = [null_resource.func_source_changed]
  }
}

resource "null_resource" "func_app_deploy" {
  provisioner "local-exec" {
    interpreter = ["pwsh", "-Command"]
    command     = <<-EOT
      az functionapp deployment source config-zip --resource-group ${azurerm_resource_group.az_project_rg.name} --name ${azurerm_windows_function_app.az_proj_func.name} --src ${archive_file.func_app_zip.output_path}
    EOT
    on_failure  = fail
  }

  lifecycle {
    replace_triggered_by = [archive_file.func_app_zip]
  }
}
