data "aws_caller_identity" "current" {}

locals {
  key_name = lower("${var.resource_prefix}-proj-${var.project_cd}-${var.environment_name}-kv")
}

