# ==============================================
#     Required Variables
# ==============================================
variable "az_subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  default     = ""
}

variable "az_tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}

variable "project_cd" {
  description = "Project short code"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "key_vault_name" {
  description = "Key vault ID"
  type        = string
}

variable "key_vault_id" {
  description = "Key vault ID"
  type        = string
}

variable "key_vault_cmk_name" {
  description = "Project CMK name"
  type        = string
}

variable "storage_acct_name" {
  description = "Project storage account"
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

variable "resource_prefix_alphanumeric" {
  description = "Aphanumeric resource name prefix for resources. All lower case"
  type        = string
  default     = "fsdh"
}

variable "project_tags" {
  description = "Project workspace common tags map"
  type        = map(any)
  default     = {}
}

variable "log_analytics_workspace_id" {
  description = "FSDH central LAW ID for storing audit and log"
  type        = string
}

variable "container_app_size" { default = "D4" }
variable "container_app_max_node" { default = "2" }
variable "container_app_min_node" { default = "0" }
variable "container_app_profile" { default = "Consumption" }
variable "app_fileshare_name" { default = "app" }
variable "container_ingress_port" { default = "80" }
variable "storage_key_secret_id" {}
variable "storage_conn_secret_id" {}
variable "storage_sas_secret_id" {}

variable "container_app_secrets" {
  type = list(object(
    {
      name      = string
      secret_id = string
    }
  ))
  default = [
    # {
    #   name      = "TEST-SECRET"
    #   secret_id = "https://fsdh-proj-s2509d-dev-kv.vault.azure.net/secrets/storage-key/0f63f366c76e498495d384e2a1ca3637"
    # }
  ]
}
variable "container_app_list" {
  type = list(object({
    name   = string
    image  = string
    cpu    = string
    memory = string
    volumes = list(object({
      name     = string
      path     = string
      sub_path = string
    }))
    env = list(object({
      name  = string
      value = string
    }))
  }))
  default = [
    # {
    #   name   = "nginx"
    #   image  = "nginx:alpine"
    #   cpu    = "0.25"
    #   memory = "0.5Gi"
    #   volumes = [{
    #     name     = "app"
    #     path     = "/etc/nginx/conf.d"
    #     sub_path = "sample/conf"
    #   }]
    #   env = [{
    #     name  = "TEST_ENV"
    #     value = "demo1"
    #   }]
    # }
  ]
}
