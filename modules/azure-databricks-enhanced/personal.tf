data "databricks_cluster_policy" "personal" {
  name = "Personal Compute"

  depends_on = [azurerm_private_endpoint.datahub_proj_databricks_api_ep]
}

resource "databricks_token" "terraform_pat" {
  comment          = "Terraform Provisioning"
  lifetime_seconds = 3600
}

data "http" "post_personal_policy_changes" {
  url    = "https://${azapi_resource.fsdh_databricks.output.properties.workspaceUrl}/api/2.0/policies/clusters/edit"
  method = "POST"

  request_headers = {
    Authorization = "Bearer ${databricks_token.terraform_pat.token_value}"
  }

  request_body = jsonencode({
    policy_id                          = "${data.databricks_cluster_policy.personal.id}",
    name                               = "Personal Compute",
    policy_family_id                   = "personal-vm",
    policy_family_definition_overrides = <<-EOF
      { 
        "autotermination_minutes":{"type":"range","defaultValue":60,"isOptional":true,"maxValue":1440,"hidden":false}, 
        "spark_conf.fs.azure.sas.fixed.token.${var.storage_acct_name}.dfs.core.windows.net":{"type":"fixed","value":"{{secrets/datahub/container-sas}}","hidden":true}, 
        "spark_conf.fs.azure.account.auth.type.${var.storage_acct_name}.dfs.core.windows.net":{"type":"fixed","value":"SAS","hidden":true}, 
        "spark_conf.fs.azure.sas.token.provider.type.${var.storage_acct_name}.dfs.core.windows.net":{"type":"fixed","value":"org.apache.hadoop.fs.azurebfs.sas.FixedSASTokenProvider","hidden":true}, 
      }
    EOF
    }
  )
}
