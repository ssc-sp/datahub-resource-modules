resource "null_resource" "datahub_proj_storage_alert" {
  count = var.storage_size_limit_tb > 0 ? 1 : 0

  provisioner "local-exec" {
    interpreter = ["pwsh", "-Command"]
    command     = <<-EOT
      az monitor metrics alert create -g ${azurerm_resource_group.az_project_rg.name} -n alertUsedCapacity --scopes ${azurerm_storage_account.datahub_storageaccount.id} --description "Storage used space" --condition "avg UsedCapacity > ${local.storage_size_limit_bytes}" --window-size 12h --evaluation-frequency 1h --action "${azurerm_monitor_action_group.datahub_proj_action_group_email.id}"
    EOT
    on_failure  = fail
  }

  provisioner "local-exec" { # Run config: az configure --defaults group=<project resource group>
    when        = destroy
    interpreter = ["pwsh", "-Command"]
    command     = "az monitor metrics alert delete -n alertUsedCapacity "
  }

  depends_on = [null_resource.az_configure_rg]
}

resource "null_resource" "az_configure_rg" {
  provisioner "local-exec" {
    interpreter = ["pwsh", "-Command"]
    command     = "az configure --defaults group=${azurerm_resource_group.az_project_rg.name}"
    on_failure  = fail
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

