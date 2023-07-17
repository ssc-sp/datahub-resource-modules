resource "aws_s3_bucket" "datahub_s3_proj" {
  bucket = "fsdhprojsw2dev"
  acl    = "private"

  versioning {
    enabled = true
  }
}