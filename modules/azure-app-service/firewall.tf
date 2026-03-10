resource "null_resource" "access_ip_whitelist_one" {
  triggers = {
    rg_name   = var.resource_group_name
    app_name  = azurerm_linux_web_app.datahub_proj_app.name
    source_ip = var.allow_source_ip
  }

  provisioner "local-exec" {
    interpreter = ["pwsh", "-Command"]
    command     = <<-EOT
      if ( ! [string]::IsNullOrEmpty("${var.allow_source_ip}") ) { 
        az webapp config access-restriction add -g ${var.resource_group_name} -n ${azurerm_linux_web_app.datahub_proj_app.name} --rule-name fsdh-app-trusted --action Allow --ip-address "${var.allow_source_ip}" --priority 100
      }
    EOT
    on_failure  = fail
  }

  provisioner "local-exec" {
    when        = destroy
    interpreter = ["pwsh", "-Command"]
    command     = <<-EOT
      az webapp config access-restriction remove -g ${self.triggers.rg_name} -n ${self.triggers.app_name} --rule-name  fsdh-app-${each.key}
    EOT
    on_failure  = continue
  }
}
