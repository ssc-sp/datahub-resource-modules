resource "time_sleep" "wait_for_databricks_workspace" {
  depends_on = [azapi_resource.fsdh_databricks]

  create_duration = "120s"
}

resource "databricks_schema" "datahub_proj_schema" {
  catalog_name = databricks_catalog.datahub_proj_catalog.name
  name         = "fsdh"
}

data "databricks_group" "admins" {
  display_name = "admins"
  depends_on   = [time_sleep.wait_for_databricks_workspace, azurerm_private_endpoint.datahub_proj_databricks_api_ep]
}

data "databricks_group" "users" {
  display_name = "users"
  depends_on   = [azurerm_private_endpoint.datahub_proj_databricks_api_ep]
}

resource "databricks_group" "project_users" {
  display_name               = "project_users"
  allow_cluster_create       = false
  allow_instance_pool_create = false
  databricks_sql_access      = true
  workspace_access           = true

  depends_on = [time_sleep.wait_for_databricks_workspace]
}

resource "databricks_group" "project_lead" {
  display_name               = "project_lead"
  allow_cluster_create       = false
  allow_instance_pool_create = false
  databricks_sql_access      = true
  workspace_access           = true

  depends_on = [time_sleep.wait_for_databricks_workspace]
}

resource "databricks_group" "project_guest" {
  display_name               = "project_guest"
  allow_cluster_create       = false
  allow_instance_pool_create = false
  databricks_sql_access      = true
  workspace_access           = true

  depends_on = [time_sleep.wait_for_databricks_workspace]
}

data "http" "create_group_lead" {
  url    = "https://${azapi_resource.fsdh_databricks.output.properties.workspaceUrl}/api/2.0/account/scim/v2/Groups"
  method = "POST"

  request_headers = { Authorization = "Bearer ${databricks_token.terraform_pat.token_value}" }
  request_body    = jsonencode({ "displayName" : "${local.group_name_lead}" })
}

data "http" "create_group_user" {
  url    = "https://${azapi_resource.fsdh_databricks.output.properties.workspaceUrl}/api/2.0/account/scim/v2/Groups"
  method = "POST"

  request_headers = { Authorization = "Bearer ${databricks_token.terraform_pat.token_value}" }
  request_body    = jsonencode({ "displayName" : "${local.group_name_user}" })
}

data "http" "create_group_guest" {
  url    = "https://${azapi_resource.fsdh_databricks.output.properties.workspaceUrl}/api/2.0/account/scim/v2/Groups"
  method = "POST"

  request_headers = { Authorization = "Bearer ${databricks_token.terraform_pat.token_value}" }
  request_body    = jsonencode({ "displayName" : "${local.group_name_guest}" })
}

data "http" "get_group_lead" {
  url    = "https://${azapi_resource.fsdh_databricks.output.properties.workspaceUrl}/api/2.0/account/scim/v2/Groups?filter=displayName+eq+\"${local.group_name_lead}\""
  method = "GET"

  request_headers = { Authorization = "Bearer ${databricks_token.terraform_pat.token_value}" }
  depends_on      = [data.http.create_group_lead]
}

data "http" "get_group_user" {
  url    = "https://${azapi_resource.fsdh_databricks.output.properties.workspaceUrl}/api/2.0/account/scim/v2/Groups?filter=displayName+eq+\"${local.group_name_user}\""
  method = "GET"

  request_headers = { Authorization = "Bearer ${databricks_token.terraform_pat.token_value}" }
  depends_on      = [data.http.create_group_user]
}

data "http" "get_group_guest" {
  url    = "https://${azapi_resource.fsdh_databricks.output.properties.workspaceUrl}/api/2.0/account/scim/v2/Groups?filter=displayName+eq+\"${local.group_name_guest}\""
  method = "GET"

  request_headers = { Authorization = "Bearer ${databricks_token.terraform_pat.token_value}" }
  depends_on      = [data.http.create_group_user]
}

resource "databricks_permission_assignment" "sync_group_lead" {
  principal_id = jsondecode(data.http.get_group_lead.response_body).Resources[0].id
  permissions  = ["USER"]
}

resource "databricks_permission_assignment" "sync_group_user" {
  principal_id = jsondecode(data.http.get_group_user.response_body).Resources[0].id
  permissions  = ["USER"]
}

resource "databricks_permission_assignment" "sync_group_guest" {
  principal_id = jsondecode(data.http.get_group_guest.response_body).Resources[0].id
  permissions  = ["USER"]
}

resource "databricks_entitlements" "group_entitlement_lead" {
  group_id                   = jsondecode(data.http.get_group_lead.response_body).Resources[0].id
  allow_cluster_create       = true
  allow_instance_pool_create = true
  databricks_sql_access      = true
  workspace_access           = true

  depends_on = [databricks_permission_assignment.sync_group_lead]
}

resource "databricks_entitlements" "group_entitlement_user" {
  group_id                   = jsondecode(data.http.get_group_user.response_body).Resources[0].id
  allow_cluster_create       = false
  allow_instance_pool_create = false
  databricks_sql_access      = true
  workspace_access           = true

  depends_on = [databricks_permission_assignment.sync_group_user]
}

resource "databricks_entitlements" "group_entitlement_guest" {
  group_id                   = jsondecode(data.http.get_group_guest.response_body).Resources[0].id
  allow_cluster_create       = false
  allow_instance_pool_create = false
  databricks_sql_access      = true
  workspace_access           = true

  depends_on = [databricks_permission_assignment.sync_group_guest]
}
