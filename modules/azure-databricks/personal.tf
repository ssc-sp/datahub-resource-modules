data "databricks_cluster_policy" "personal" {
  name = "Personal Compute"
}

resource "databricks_token" "terraform_pat" {
  comment          = "Terraform Provisioning"
  lifetime_seconds = 3600
}

data "http" "post_personal_policy_change" {
  url    = "https://${azurerm_databricks_workspace.datahub_databricks_workspace.workspace_url}/api/2.0/policies/clusters/edit"
  method = "POST"

  request_headers = {
    Authorization = "Bearer ${databricks_token.terraform_pat.token_value}"
  }

  request_body = jsonencode({
    policy_id                          = "${data.databricks_cluster_policy.personal.id}",
    name                               = "Personal Compute",
    policy_family_id                   = "personal-vm",
    policy_family_definition_overrides = "{\"autotermination_minutes\":{\"type\":\"range\",\"defaultValue\":60,\"isOptional\":true,\"maxValue\":1440,\"hidden\":false}}"
    }
  )
}
