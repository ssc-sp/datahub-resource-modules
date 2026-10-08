resource "azurerm_logic_app_workflow" "fsdh_logicapp_message_forwarder" {
  name                = local.logicapp_name
  location            = local.resource_group_location
  resource_group_name = azurerm_resource_group.az_project_rg.name
  enabled             = true

  identity { type = "SystemAssigned" }
  workflow_schema  = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
  workflow_version = "1.0.0.0"

  tags = local.project_tags
  parameters = {
    "$connections" = jsonencode({
      azurequeues = {
        connectionId         = azapi_resource.azurequeues_connection.id
        connectionName       = azapi_resource.azurequeues_connection.name
        connectionProperties = { authentication = { type = "ManagedServiceIdentity" } }
        id                   = "/subscriptions/${var.az_subscription_id}/providers/Microsoft.Web/locations/${local.resource_group_location}/managedApis/azurequeues"
      }

      servicebus = {
        connectionId         = azapi_resource.servicebus_connection.id
        connectionName       = azapi_resource.servicebus_connection.name
        connectionProperties = { authentication = { type = "ManagedServiceIdentity" } }
        id                   = "/subscriptions/${var.az_subscription_id}/providers/Microsoft.Web/locations/${local.resource_group_location}/managedApis/servicebus"
      }
    })
  }
  workflow_parameters = {
    "$connections"     = jsonencode({ defaultValue = {}, type = "Object" })
    storageAccountName = jsonencode({ defaultValue = "${azurerm_storage_account.datahub_storageaccount.name}", type = "String" })
  }
}

resource "azurerm_logic_app_trigger_custom" "logicapp_trigger_queue" {
  name         = "When_there_are_messages_in_a_queue_(V2)"
  logic_app_id = azurerm_logic_app_workflow.fsdh_logicapp_message_forwarder.id

  body = jsonencode({
    conditions = []
    inputs = {
      host = {
        connection = {
          name = "@parameters('$connections')['azurequeues']['connectionId']"
        }
      }
      method = "get"
      path   = "/v2/storageAccounts/@{encodeURIComponent(encodeURIComponent(parameters('storageAccountName')))}/queues/@{encodeURIComponent('${local.clamav_result_queue}')}/message_trigger"
    }
    recurrence = {
      interval  = 1
      frequency = "Minute"
    }
    splitOn = "@triggerBody()?['QueueMessagesList']?['QueueMessage']"
    type    = "ApiConnection"
  })
}

resource "azurerm_logic_app_action_custom" "logicapp_action_compose" {
  name         = "Compose_message"
  logic_app_id = azurerm_logic_app_workflow.fsdh_logicapp_message_forwarder.id

  body = jsonencode({
    inputs   = "@triggerBody()"
    runAfter = {}
    type     = "Compose"
  })
}

resource "azurerm_logic_app_action_custom" "logicapp_action_send_message_to_servicebus" {
  name         = "Send_message"
  logic_app_id = azurerm_logic_app_workflow.fsdh_logicapp_message_forwarder.id

  body = jsonencode({
    inputs = {
      body = {
        ContentData = "@base64(triggerBody()?['MessageText'])"
      }
      host = {
        connection = {
          name = "@parameters('$connections')['servicebus']['connectionId']"
        }
      }
      method = "post"
      path   = "/@{encodeURIComponent(encodeURIComponent('${local.clamav_result_queue}'))}/messages"
      queries = {
        systemProperties = "None"
      }
    }
    runAfter = { "${azurerm_logic_app_action_custom.logicapp_action_compose.name}" = ["Succeeded"] }
    type     = "ApiConnection"
  })
}

resource "azurerm_logic_app_action_custom" "logicapp_action_delete_message" {
  name         = "Delete_message"
  logic_app_id = azurerm_logic_app_workflow.fsdh_logicapp_message_forwarder.id

  body = jsonencode({
    inputs = {
      host = {
        connection = {
          name = "@parameters('$connections')['azurequeues']['connectionId']"
        }
      }
      method = "delete"
      path   = "/v2/storageAccounts/@{encodeURIComponent(encodeURIComponent(parameters('storageAccountName')))}/queues/@{encodeURIComponent('${local.clamav_result_queue}')}/messages/@{encodeURIComponent(triggerBody()?['MessageId'])}"
      queries = {
        popreceipt = "@triggerBody()?['PopReceipt']"
      }
    }
    runAfter = { "${azurerm_logic_app_action_custom.logicapp_action_send_message_to_servicebus.name}" = ["Succeeded"] }
    type     = "ApiConnection"
  })
}

# resource "azurerm_api_connection" "api_conn_azurequeues_1" {
#   display_name        = "clam-av-queue1"
#   managed_api_id      = "/subscriptions/${var.az_subscription_id}/providers/Microsoft.Web/locations/${var.az_location}/managedApis/azurequeues"
#   resource_group_name = azurerm_resource_group.az_project_rg.name
#   name                = "azurequeues"
#   parameter_values    = { managedIdentityAuth = "{}" }
# }

# resource "azurerm_api_connection" "api_conn_servicebus_1" {
#   display_name        = "fsdh-service-bus-dev-clamav"
#   managed_api_id      = "/subscriptions/${var.az_subscription_id}/providers/Microsoft.Web/locations/${var.az_location}/managedApis/servicebus"
#   name                = "servicebus"
#   parameter_values    = { connectionString = "Endpoint=sb://fsdh-service-bus-dev.servicebus.windows.net/" }
#   resource_group_name = azurerm_resource_group.az_project_rg.name
# }

resource "azapi_resource" "azurequeues_connection" {
  type                      = "Microsoft.Web/connections@2016-06-01"
  name                      = "azurequeues"
  parent_id                 = azurerm_resource_group.az_project_rg.id
  location                  = var.az_location
  schema_validation_enabled = false

  body = {
    properties = {
      displayName = "clam-av-queue1"
      api         = { id = "/subscriptions/${var.az_subscription_id}/providers/Microsoft.Web/locations/${var.az_location}/managedApis/azurequeues" }
      parameterValueSet = {
        name   = "managedIdentityAuth"
        values = {}
      }
    }
  }
}

resource "azapi_resource" "servicebus_connection" {
  type                      = "Microsoft.Web/connections@2016-06-01"
  name                      = "servicebus"
  parent_id                 = azurerm_resource_group.az_project_rg.id
  location                  = var.az_location
  schema_validation_enabled = false

  body = {
    properties = {
      displayName = "clamav-av-servicebus"
      api         = { id = "/subscriptions/${var.az_subscription_id}/providers/Microsoft.Web/locations/${var.az_location}/managedApis/servicebus" }
      parameterValueSet = {
        name = "managedIdentityAuth"
        values = {
          namespaceEndpoint = { value = "sb://${local.service_bus_name}.servicebus.windows.net/" }
        }
      }
    }
  }
}

