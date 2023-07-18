resource "aws_kms_key" "datahub_proj_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Id": "key-default-1",
    "Statement": [
      {
        "Sid": "Enable IAM User Permissions",
        "Effect": "Allow",
        "Principal": {
            "AWS": [
                "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            ]
        },
        "Action": "kms:*",
        "Resource": "*"
      }
    ]
  }
  POLICY
}

resource "aws_kms_alias" "datahub_proj_key_alias" {
  name          = "alias/${local.key_name}"
  target_key_id = aws_kms_key.datahub_proj_key.key_id
}

