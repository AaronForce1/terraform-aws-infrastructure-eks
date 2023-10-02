## ----------------------------------
## AWS KMS PRIMARY KEY
## ----------------------------------
resource "aws_kms_key" "kms-key" {
  description             = "${var.aws_kms_name} KMS Encryption Key"
  multi_region            = "true"
  enable_key_rotation     = true
  deletion_window_in_days = 30
  policy = jsonencode({
    Version = "2012-10-17",
    "Id" : "key-default-1",
    "Statement" : [
      {
        "Sid" : "Enable IAM User Permissions",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action" : "kms:*",
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "logs.${data.aws_region.current.name}.amazonaws.com"
        },
        "Action" : [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ],
        "Resource" : "*",
        "Condition" : {
          "ArnEquals" : {
            "kms:EncryptionContext:aws:logs:arn" : "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
          }
        }
      }
    ]
  })
}

## ----------------------------------
## AWS KMS ALIAS
## ----------------------------------
resource "aws_kms_alias" "kms" {
  name          = "alias/${var.aws_kms_name}-kms"
  target_key_id = aws_kms_key.kms-key.key_id
}

## ----------------------------------
## AWS KMS REPLICAS KEY
## ----------------------------------
resource "aws_kms_replica_key" "kms" {
  description             = "${var.aws_kms_name} EKS Replica Key (Multi-Region)"
  deletion_window_in_days = 30
  primary_key_arn         = aws_kms_key.kms-key.arn
  provider                = aws.secondary
}