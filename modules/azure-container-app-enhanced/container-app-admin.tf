resource "azurerm_container_app" "proj_admin_app" {
  name                         = "${var.project_cd}-${var.environment_name}-aca-admin"
  container_app_environment_id = var.aca_env_id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.proj_aca_uami.id]
  }

  template {
    container {
      name   = "admin"
      image  = "ghcr.io/linuxserver/nginx"
      cpu    = 0.25
      memory = "0.5Gi"
    }

    min_replicas                     = 0
    max_replicas                     = 1
    termination_grace_period_seconds = 120
  }

  ingress {
    external_enabled = true
    target_port      = 80
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  tags = var.project_tags

  lifecycle {
    ignore_changes = [tags]
  }
}
