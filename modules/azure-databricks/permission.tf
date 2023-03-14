resource "databricks_permissions" "main_cluster_usage" {
  cluster_id = databricks_cluster.dbk_proj_cluster.cluster_id

  access_control {
    group_name       = databricks_group.project_lead.display_name
    permission_level = "CAN_ATTACH_TO"
  }

  access_control {
    group_name       = databricks_group.project_users.display_name
    permission_level = "CAN_ATTACH_TO"
  }

  access_control {
    group_name       = databricks_group.project_lead.display_name
    permission_level = "CAN_RESTART"
  }

  access_control {
    group_name       = databricks_group.project_users.display_name
    permission_level = "CAN_RESTART"
  }

  access_control {
    group_name       = databricks_group.project_lead.display_name
    permission_level = "CAN_MANAGE"
  }
}

resource "databricks_permissions" "regular_policy_usage" {
  cluster_policy_id = databricks_cluster_policy.regular_cluster_policy.id

  access_control {
    group_name       = databricks_group.project_lead.display_name
    permission_level = "CAN_USE"
  }

  access_control {
    group_name       = databricks_group.project_users.display_name
    permission_level = "CAN_USE"
  }
}

resource "databricks_permissions" "small_policy_usage" {
  cluster_policy_id = databricks_cluster_policy.small_cluster_policy.id

  access_control {
    group_name       = databricks_group.project_lead.display_name
    permission_level = "CAN_USE"
  }

  access_control {
    group_name       = databricks_group.project_users.display_name
    permission_level = "CAN_USE"
  }
}

resource "databricks_permissions" "large_policy_usage" {
  cluster_policy_id = databricks_cluster_policy.large_cluster_policy.id

  access_control {
    group_name       = databricks_group.project_lead.display_name
    permission_level = "CAN_USE"
  }
}