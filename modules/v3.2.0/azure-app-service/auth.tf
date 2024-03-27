resource "null_resource" "sp_add_app_service_redirect_uri" {
  count = var.use_easy_auth ? 1 : 0

  provisioner "local-exec" {
    interpreter = ["pwsh", "-Command"]
    command     = <<-EOT
      $uris = ((az ad app show --id ${var.sp_client_id}|convertfrom-json).web.redirecturis) + "https://${local.dns_record_name}.${var.fsdh_dns_zone_name}/.auth/login/aad/callback"
      $uris
      az ad app update --id ${var.sp_client_id} --web-redirect-uris $uris
    EOT
    on_failure  = fail
  }
}