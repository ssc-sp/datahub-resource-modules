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
  }

  site_config {
    always_on = "true" # BELOW: define the images to used for you application

    application_stack {
      docker_image     = var.shiny_image_name
      docker_image_tag = var.shiny_image_tag
    }
  }

  auth_settings_v2 {
    auth_enabled           = true
    require_authentication = true
    require_https          = true

    active_directory_v2 {
      client_secret_setting_name = "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"
      client_id                  = var.sp_client_id
      tenant_auth_endpoint       = "https://sts.windows.net/${data.azurerm_client_config.current.tenant_id}/v2.0"
    }

    login {
      token_store_enabled = true
    }
  }

  identity {
    type = "SystemAssigned"
  }
}

