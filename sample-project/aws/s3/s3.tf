resource "aws_s3_bucket" "datahub_s3_proj" {
  bucket = local.s3_name
  acl    = "private"

  versioning { enabled = false }


  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = var.project_key_arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}
