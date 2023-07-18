output "aws_project_key_name" {
  value = aws_kms_alias.datahub_proj_key_alias.name
}

output "aws_project_key_arn" {
  value = aws_kms_key.datahub_proj_key.arn
}

output "project_cd" {
  value = var.project_cd
}