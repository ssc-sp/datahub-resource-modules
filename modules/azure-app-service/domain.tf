resource "azurerm_dns_cname_record" "datahub_app_cname" {
  count = var.use_easy_auth ? 1 : 0

  name                = local.dns_record_name
  zone_name           = var.fsdh_dns_zone_name
  resource_group_name = var.fsdh_dns_zone_rg
  ttl                 = 120
  record              = azurerm_linux_web_app.datahub_proj_shiny_app.default_hostname
}

resource "azurerm_dns_txt_record" "datahub_dns_txt_record" {
  count = var.use_easy_auth ? 1 : 0

  name                = "asuid.${local.dns_record_name}.${var.fsdh_dns_zone_name}"
  zone_name           = var.fsdh_dns_zone_name
  resource_group_name = var.fsdh_dns_zone_rg
  ttl                 = 120
  record {
    value = azurerm_linux_web_app.datahub_proj_shiny_app.custom_domain_verification_id
  }
}

resource "time_sleep" "wait_for_dns_txt" {
  depends_on = [azurerm_dns_txt_record.datahub_dns_txt_record, azurerm_dns_cname_record.datahub_app_cname]

  create_duration = "125s"
}

resource "azurerm_app_service_custom_hostname_binding" "datahub_app_custom_host" {
  count = var.use_easy_auth ? 1 : 0

  hostname            = "${local.dns_record_name}.${var.fsdh_dns_zone_name}"
  app_service_name    = azurerm_linux_web_app.datahub_proj_shiny_app.name
  resource_group_name = var.resource_group_name

  depends_on = [time_sleep.wait_for_dns_txt]
  lifecycle {
    ignore_changes = [ssl_state, thumbprint]
  }
}

# If getting error, temporarily comment out this resource and run to completion before re-enabling
resource "azurerm_app_service_certificate_binding" "datahub_ssl_binding" {
  count = var.use_easy_auth ? 1 : 0

  hostname_binding_id = azurerm_app_service_custom_hostname_binding.datahub_app_custom_host[0].id
  certificate_id      = azurerm_app_service_certificate.datahub_ssl_cert[0].id
  ssl_state           = "SniEnabled"
}

data "azurerm_key_vault_secret" "datahub_ssl_cert" {
  count = var.use_easy_auth ? 1 : 0

  name         = var.ssl_cert_name
  key_vault_id = var.ssl_cert_kv_id
}

resource "azurerm_app_service_certificate" "datahub_ssl_cert" {
  count = var.use_easy_auth ? 1 : 0

  name                = "datahub-app-cert-kv"
  resource_group_name = var.resource_group_name
  location            = local.resource_group_location
  pfx_blob            = data.azurerm_key_vault_secret.datahub_ssl_cert[0].value

  depends_on = [time_sleep.wait_for_dns_txt]

  tags = merge(
    var.common_tags
  )

  lifecycle {
    ignore_changes = [pfx_blob]
  }
}
