# Creates one Container App Job per entry in local.jobs
resource "azurerm_container_app_job" "jobs" {
  for_each = local.jobs

  name                         = "${local.base_name}-${replace(each.key, "_", "-")}-job"
  container_app_environment_id = azurerm_container_app_environment.proj_container_app_env.id
  location                     = local.resource_group_location
  resource_group_name          = azurerm_resource_group.az_project_rg.name
  replica_timeout_in_seconds   = 1800

  identity {
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.proj_auto_acct_uai.id]
  }

  template {
    container {
      name   = each.key
      image  = each.value.image
      cpu    = each.value.cpu
      memory = each.value.memory

      # Merge common + job-specific env into discrete env blocks
      dynamic "env" {
        for_each = merge(local.common_env, lookup(each.value, "env", {}))
        content {
          name  = env.key
          value = env.value
        }
      }
    }
  }

  schedule_trigger_config {
    cron_expression = each.value.schedule_cron
  }
}
