locals {
  s3_name = lower("${var.resource_prefix}projs3${var.project_cd}${var.environment_name}")
}

