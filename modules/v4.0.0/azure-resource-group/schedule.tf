resource "random_integer" "hour" {
  min = 1
  max = 9
}

resource "random_integer" "min" {
  min = 10
  max = 59
}

resource "random_integer" "sec" {
  min = 10
  max = 59
}

resource "azurerm_automation_schedule" "daily_3am_schedule" {
  name                    = "daily-3am-schedule"
  resource_group_name     = azurerm_resource_group.az_project_rg.name
  automation_account_name = azurerm_automation_account.az_project_automation_acct.name
  frequency               = "Day"
  interval                = 1
  timezone                = "America/Toronto"
  start_time              = "${formatdate("YYYY-MM-DD", timeadd(timestamp(), "24h"))}T${random_integer.hour.result}:${random_integer.min.result}:${random_integer.sec.result}Z"
  description             = "DataHub Schedule to check RG spend daily"

  lifecycle {
    ignore_changes = [start_time]
  }
}
