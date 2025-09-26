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

variable "automation_account_uai_sub" {
  description = "The RG of the automation acct UAI"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "FSDH central LAW ID for storing audit and log"
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

variable "ssc_cbrid" {
  description = "CBR tag for the workspace"
  type        = string
  default     = ""
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

# ==============================================
#     Container Image & Resource Variables
# ==============================================

variable "blob_scan_image" {
  description = "Container image for the blob scanning job"
  type        = string
  default     = "ghcr.io/ssc-sp/clamav-blobavscan:latest"
}

variable "proj_cost_image" {
  description = "Container image for the project costing job"
  type        = string
  default     = "ghcr.io/ssc-sp/projcost:latest"
}

variable "proj_sas_image" {
  description = "Container image for the SAS worker job"
  type        = string
  default     = "ghcr.io/fsdh-pfds/proj-sas-worker@sha256:884cbd2506b07ac892cd1d41cb12eeb6f810e05cb94ba17f609a24b4badc9102"
}

variable "blob_scan_cpu" {
  description = "CPU cores allocated to the blob scan container"
  type        = number
  default     = 1
}

variable "blob_scan_memory" {
  description = "Memory allocated to the blob scan container"
  type        = string
  default     = "2.0Gi"
}

variable "proj_cost_cpu" {
  description = "CPU cores allocated to the proj cost container"
  type        = number
  default     = 2
}

variable "proj_cost_memory" {
  description = "Memory allocated to the proj cost container"
  type        = string
  default     = "4.0Gi"
}

variable "proj_sas_cpu" {
  description = "CPU cores allocated to the proj sas container"
  type        = number
  default     = 1
}

variable "proj_sas_memory" {
  description = "Memory allocated to the proj sas container"
  type        = string
  default     = "2.0Gi"
}

# Optional per-job overrides. Keys: "proj-cost", "blob-scan", "proj-sas".
# Any provided attribute overrides the default for that job.
# (Requires Terraform v1.3+ for 'optional' in object types.)
variable "jobs_override" {
  description = "Per-job overrides (image, cpu, memory, schedule_cron, env) keyed by job name."
  type = map(object({
    image         = optional(string)
    cpu           = optional(number)
    memory        = optional(string)
    schedule_cron = optional(string)
    env           = optional(map(string))
  }))
  default = {}
}
