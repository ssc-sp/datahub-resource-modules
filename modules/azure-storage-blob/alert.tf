# Use null_resource due to bug https://github.com/hashicorp/terraform-provider-azurerm/issues/15223

# resource "azurerm_monitor_metric_alert" "datahub_proj_storage_alert" {
#   count = var.storage_size_limit_tb > 0 ? 1 : 0

#   name                = "${var.resource_prefix}-proj-storage-alert-${var.project_cd}-${var.environment_name}"
#   resource_group_name = var.resource_group_name
#   scopes              = [azurerm_storage_account.datahub_storageaccount.id]
#   description         = "Action will be triggered when used space reaches thresholds"
#   window_size         = "PT12H"
#   frequency           = "PT1H"
#   severity            = 2

#   criteria {
#     metric_namespace = "Microsoft.Storage/storageAccounts"
#     metric_name      = "UsedCapacity"
#     aggregation      = "Average"
#     operator         = "GreaterThan"
#     threshold        = 1024 * 1024 * 1024 * 1024 * var.storage_size_limit_tb
#   }

#   action {
#     action_group_id = data.azurerm_monitor_action_group.datahub_proj_action_group_email.id
#   }
# }

resource "null_resource" "datahub_proj_storage_alert" {
  count = var.storage_size_limit_tb > 0 ? 1 : 0

  provisioner "local-exec" {
    interpreter = ["pwsh", "-Command"]
    command     = <<-EOT
      az monitor metrics alert create -g ${var.resource_group_name} -n alertUsedCapacity --scopes ${azurerm_storage_account.datahub_storageaccount.id} --description "Storage used space" --condition "avg UsedCapacity > ${local.storage_size_limit_bytes}" --window-size 12h --evaluation-frequency 1h --action "${data.azurerm_monitor_action_group.datahub_proj_action_group_email.id}"
    EOT
    on_failure  = fail
  }

  provisioner "local-exec" {
    when        = destroy
    interpreter = ["pwsh", "-Command"]
    command     = "az monitor metrics alert delete -n alertUsedCapacity"
  }
}
