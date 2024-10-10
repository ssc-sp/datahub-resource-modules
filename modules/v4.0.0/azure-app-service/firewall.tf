resource "null_resource" "access_ip_block_all" {
  count = var.allow_source_ip == "" ? 1 : 0

  triggers = {
    rg_name  = var.resource_group_name
    app_name = azurerm_linux_web_app.datahub_proj_app.name
  }

  provisioner "local-exec" {
    interpreter = ["pwsh", "-Command"]
    command     = <<-EOT
      az webapp config access-restriction add -g ${var.resource_group_name} -n ${azurerm_linux_web_app.datahub_proj_app.name} --rule-name block-all --action Deny --ip-address 0.0.0.0/0 --priority 999
    EOT
    on_failure  = fail
  }

  provisioner "local-exec" {
    when        = destroy
    interpreter = ["pwsh", "-Command"]
    command     = <<-EOT
      az webapp config access-restriction remove -g ${self.triggers.rg_name} -n ${self.triggers.app_name} --rule-name block-all
    EOT
    on_failure  = continue
  }
}

resource "null_resource" "access_ip_whitelist_one" {
  for_each = { for s in local.allow_source_ip_list : index(local.allow_source_ip_list, s) => s }

  triggers = {
    rg_name   = var.resource_group_name
    app_name  = azurerm_linux_web_app.datahub_proj_app.name
    source_ip = each.value
  }

  provisioner "local-exec" {
    interpreter = ["pwsh", "-Command"]
    command     = <<-EOT
      $ip_addr="${each.value}".trim()
      if ( ! [string]::IsNullOrEmpty("$ip_addr") ) { 
        az webapp config access-restriction add -g ${var.resource_group_name} -n ${azurerm_linux_web_app.datahub_proj_app.name} --rule-name fsdh-app-${each.key} --action Allow --ip-address "$ip_addr/32" --priority ${100 + each.key}
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