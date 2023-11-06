resource "azurerm_service_plan" "datahub_proj_app_service_plan" {
  name                = local.app_service_plan_name
  resource_group_name = var.resource_group_name
  location            = local.resource_group_location
  sku_name            = var.app_service_sku
  os_type             = "Linux"
  worker_count        = var.worker_count_init

  tags = merge(local.project_tags)
}

resource "azurerm_linux_web_app" "datahub_proj_shiny_app" {
  name                    = local.app_service_name_shiny
  resource_group_name     = var.resource_group_name
  location                = local.resource_group_location
  service_plan_id         = azurerm_service_plan.datahub_proj_app_service_plan.id
  https_only              = true
  client_affinity_enabled = true

  app_settings = {
    DOCKER_REGISTRY_SERVER_URL          = var.docker_server_url
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
    WEBSITES_PORT                       = "3838"
    APP_FOLDER                          = "shiny"
    BLOB_ACCOUNT_KEY                    = "@Microsoft.KeyVault(VaultName=${var.key_vault_name};SecretName=${local.storage_key_secret})"
    BLOB_ACCOUNT_NAME                   = var.storage_acct_name
    BLOB_CONTAINER_NAME                 = local.storage_acct_mount
    SSH_PASSWD                          = "@Microsoft.KeyVault(VaultName=${var.key_vault_name};SecretName=${local.root_passwd_secret})"
    BLOB_ACCOUNT_URL                    = "https://${var.storage_acct_name}.blob.core.windows.net"
    BLOB_SAS_TOKEN                      = "@Microsoft.KeyVault(VaultName=${var.key_vault_name};SecretName=${local.storage_sas_secret})"
  }

  site_config {
    always_on = "true" # BELOW: define the images to used for you application

    application_stack {
      docker_image     = var.shiny_image_name
      docker_image_tag = var.shiny_image_tag
    }
  }

  storage_account {
    access_key   = data.azurerm_key_vault_secret.storage_key.value
    account_name = var.storage_acct_name
    name         = local.storage_acct_mount
    share_name   = local.storage_acct_mount
    type         = "AzureBlob"
    mount_path   = "/${local.storage_acct_mount}"
  }

  # auth_settings_v2 {
  #   auth_enabled           = true
  #   require_authentication = true
  #   require_https          = true

  #   active_directory_v2 {
  #     client_secret_setting_name = "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"
  #     client_id                  = var.sp_client_id
  #     tenant_auth_endpoint       = "https://sts.windows.net/${data.azurerm_client_config.current.tenant_id}/v2.0"
  #   }

  #   login {
  #     token_store_enabled = true
  #   }
  # }

  identity {
    type = "SystemAssigned"
  }
}

resource "null_resource" "datahub_proj_shiny_easy_auth" {
  count = var.use_easy_auth ? 1 : 0

  provisioner "local-exec" {
    interpreter = ["pwsh", "-Command"]
    command     = <<-EOT
      az webapp auth update -g ${var.resource_group_name} -n ${azurerm_linux_web_app.datahub_proj_shiny_app.name} --enabled true 
      az webapp auth microsoft update -g ${var.resource_group_name} -n ${azurerm_linux_web_app.datahub_proj_shiny_app.name} --client-id ${var.sp_client_id} --client-secret-setting-name "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET" --issuer "https://sts.windows.net/${data.azurerm_client_config.current.tenant_id}/v2.0"
    EOT
    on_failure  = fail
  }
}

resource "azurerm_role_assignment" "acr_pull" {
  count = var.acr_id == "" ? 0 : 1

  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_linux_web_app.datahub_proj_shiny_app.identity[0].principal_id
}

resource "azurerm_key_vault_access_policy" "kv_app_service_policy" {
  key_vault_id = var.key_vault_id
  tenant_id    = var.az_tenant_id
  object_id    = azurerm_linux_web_app.datahub_proj_shiny_app.identity[0].principal_id

  secret_permissions = ["Get", "List"]
}

