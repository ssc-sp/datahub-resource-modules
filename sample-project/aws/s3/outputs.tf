output "aws_project_s3" {
  value = aws_s3_bucket.datahub_s3_proj.bucket
}

output "project_cd" {
  value = var.project_cd
}