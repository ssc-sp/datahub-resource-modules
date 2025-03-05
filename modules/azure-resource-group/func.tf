resource "azurerm_service_plan" "az_proj_consumption_plan" {
  name                = local.funcapp_plan
  location            = azurerm_resource_group.az_project_rg.location
  resource_group_name = azurerm_resource_group.az_project_rg.name
  sku_name            = "Y1"
  os_type             = "Linux"
}

resource "azurerm_linux_function_app" "az_proj_func" {
  name                = local.funcapp_name
  location            = azurerm_resource_group.az_project_rg.location
  resource_group_name = azurerm_resource_group.az_project_rg.name
  service_plan_id     = azurerm_service_plan.az_proj_consumption_plan.id
  # storage_key_vault_secret_id = azurerm_key_vault_secret.datahub_seed_storageaccount_str.versionless_id
  storage_account_name       = azurerm_storage_account.datahub_seed_storageaccount.name
  storage_account_access_key = azurerm_storage_account.datahub_seed_storageaccount.primary_access_key
  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.proj_auto_acct_uai.id]
  }

  functions_extension_version = "~4"

  site_config { always_on = false }

  app_settings = {
    "ApplicationInsightsAgent_EXTENSION_VERSION"      = "~3"
    "XDT_MicrosoftApplicationInsights_Mode"           = "recommended"
    "InstrumentationEngine_EXTENSION_VERSION"         = "~1"
    "XDT_MicrosoftApplicationInsights_BaseExtensions" = "~1"
    "FUNCTIONS_WORKER_RUNTIME"                        = "powershell"
    #"WEBSITE_CONTENTAZUREFILECONNECTIONSTRING"        = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.az_proj_kv.name};SecretName=${local.seed_storage_secret_name})"
  }

  tags = merge(
    var.common_tags
  )
  depends_on = [azurerm_role_assignment.kv_role_function_py_uai]
  lifecycle {}
}

resource "azurerm_key_vault_access_policy" "kv_func_policy" {
  key_vault_id = azurerm_key_vault.az_proj_kv.id
  tenant_id    = var.az_tenant_id
  object_id    = azurerm_linux_function_app.az_proj_func.identity.0.principal_id

  secret_permissions = ["Get"]
}

resource "azurerm_role_assignment" "kv_role_function_py_uai" {
  scope                = azurerm_key_vault.az_proj_kv.id
  principal_id         = data.azurerm_user_assigned_identity.proj_auto_acct_uai.principal_id
  role_definition_name = "Key Vault Secrets User"
}


resource "azurerm_function_app_function" "datahub_proj_cost_func" {
  name            = "fsdh-check-spending"
  function_app_id = azurerm_linux_function_app.az_proj_func.id
  language        = "PowerShell"
  file {
    name    = "check-spend"
    content = data.template_file.az_project_cost_check_script.rendered
  }

  config_json = jsonencode({
    "bindings" = [
      {
        "name" : "fsdhTimer",
        "type" : "timerTrigger",
        "direction" : "in",
        "schedule" : "0 ${random_integer.logicapp_start_minute.result} ${random_integer.logicapp_start_hour.result} * * *"
      }
    ]
  })
}
