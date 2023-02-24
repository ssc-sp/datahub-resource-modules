locals {
  datahub_policy_regular = {
    "dbus_per_hour" : { "type" : "range", "maxValue" : 12 },
    "node_type_id" : { "type" : "allowlist", "values" : ["Standard_D4s_v3", "Standard_D8s_v3", "Standard_D16s_v3"], "defaultValue" : "Standard_D4s_v3" },
    "driver_node_type_id" : { "type" : "fixed", "value" : "Standard_D4s_v3", "hidden" : true },
    "autotermination_minutes" : { "type" : "fixed", "value" : 10, "hidden" : true },
    "autoscale.min_workers" : { "type" : "fixed", "value" : 1, "hidden" : true },
    "autoscale.max_workers" : { "type" : "range", "maxValue" : 4, "defaultValue" : 2 },
    "custom_tags.Team" : { "type" : "fixed", "value" : "datahub project team" }
  }

  datahub_policy_small = {
    "dbus_per_hour" : { "type" : "range", "maxValue" : 4 },
    "node_type_id" : { "type" : "fixed", "value" : "Standard_D4s_v3", "hidden" : true },
    "driver_node_type_id" : { "type" : "fixed", "value" : "Standard_D4s_v3", "hidden" : true },
    "autotermination_minutes" : { "type" : "fixed", "value" : 10, "hidden" : true },
    "autoscale.min_workers" : { "type" : "fixed", "value" : 1, "hidden" : true },
    "autoscale.max_workers" : { "type" : "range", "maxValue" : 2, "defaultValue" : 2 },
    "custom_tags.Team" : { "type" : "fixed", "value" : "datahub project team" }
  }

  datahub_policy_large = {
    "dbus_per_hour" : { "type" : "range", "maxValue" : 64 },
    "autotermination_minutes" : { "type" : "fixed", "value" : 10, "hidden" : true },
    "autoscale.min_workers" : { "type" : "fixed", "value" : 1, "hidden" : true },
    "autoscale.max_workers" : { "type" : "range", "maxValue" : 32, "defaultValue" : 2 },
    "custom_tags.Team" : { "type" : "fixed", "value" : "datahub project team" }
  }

  datahub_policy_overrides = {
    description = "Datahub Cluster policy overrides"
  }
}

resource "databricks_cluster_policy" "regular_cluster_policy" {
  name       = "Datahub Regular Cluster"
  definition = jsonencode(local.datahub_policy_regular)
}

resource "databricks_cluster_policy" "small_cluster_policy" {
  name       = "Datahub Small Cluster"
  definition = jsonencode(local.datahub_policy_small)
}

resource "databricks_cluster_policy" "large_cluster_policy" {
  name       = "Datahub Large Cluster"
  definition = jsonencode(local.datahub_policy_large)
}
