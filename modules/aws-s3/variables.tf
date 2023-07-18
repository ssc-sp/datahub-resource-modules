# ==============================================
#     Required Variables
# ==============================================
variable "project_cd" {
  description = "Project short code"
  type        = string
}

variable "project_key_arn" {
  description = "Project CMK"
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

variable "aws_location" {
  description = "The AWS region to create the resources in"
  type        = string
  default     = "ca-central-1"
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

variable "storage_contributor_users" {
  description = "A list of users to be assigned the role of Storage Blob Data Contributor"
  type        = list(any)
  default     = []
}

variable "storage_reader_users" {
  description = "A list of users to be assigned the role of Storage Blob Data Reader"
  type        = list(any)
  default     = []
}

variable "storage_size_limit_tb" {
  description = "Storage account size limit for alerts"
  type        = number
  default     = 0
}


