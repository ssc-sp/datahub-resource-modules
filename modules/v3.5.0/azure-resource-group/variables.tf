# ==============================================
#     Required Variables
# ==============================================

variable "az_subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "az_tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}

variable "project_cd" {
  description = "Project short code"
  type        = string
}

variable "datahub_app_sp_oid" {
  description = "The SP object ID used by the datahub app for granting KV access"
  type        = string
}

variable "automation_account_uai_name" {
  description = "The UAI common automation acct UAI"
  type        = string
}

variable "automation_account_uai_rg" {
  description = "The RG of the automation acct UAI"
  type        = string
}

# ==============================================
#     Optional Variables
# ==============================================
variable "environment_classification" {
  description = "Max level of security the environment hosts"
  type        = string
  default     = "U"
}

variable "environment_name" {
  description = "Short name for environment (e.g. dev, test, prod)"
  type        = string
  default     = "dev"
}

variable "az_location" {
  description = "The Azure location to create the resources in"
  type        = string
  default     = "canadacentral"
}

variable "resource_prefix" {
  description = "Resource name prefix for all resources"
  type        = string
  default     = "fsdh"
}

variable "common_tags" {
  description = "Common tags map"
  type        = map(any)
  default     = {}
}

variable "budget_amount" {
  description = "Budget amount for the resource group"
  type        = number
  default     = 0
}

variable "default_alert_email" {
  description = "Default alert email regardless of project"
  type        = string
  default     = "fsdh-notifications-dhsf-notifications@ssc-spc.gc.ca"
}

variable "project_alert_email_list" {
  description = "A list of email addresses to receive project level notification emails"
  type        = list(string)
  default     = []
}

variable "aad_admin_group_oid" {
  description = "The admin group OID in AAD for managing the datahub app"
  type        = string
}

variable "budget_start_date" {
  description = "The start date of budget"
  type        = string
  default     = ""
}


