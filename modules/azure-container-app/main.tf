resource "azurerm_container_app_environment" "datahub_proj_capp_env" {
  name                = local.container_app_env_name
  resource_group_name = var.resource_group_name
  location            = local.resource_group_location
  tags                = merge(local.project_tags)

  log_analytics_workspace_id = var.log_workspace_id
}

resource "azurerm_container_app" "datahub_proj_capp" {
  name                         = local.container_app_name
  container_app_environment_id = azurerm_container_app_environment.datahub_proj_capp_env.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  identity {
    type = "SystemAssigned"
  }

  ingress {
    target_port      = 80
    external_enabled = true
    traffic_weight {
      percentage = 100
    }
  }

  template {
    container {
      name   = "${local.container_app_name}-main"
      image  = var.container_main_image_url
      cpu    = var.container_app_cpu
      memory = "${var.container_app_ram}Gi"
    }
  }

  lifecycle {
    ignore_changes = [ template ]
  }
}
