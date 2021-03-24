resource "aws_kms_key" "eks_logging" {
  enable_key_rotation = true
  description = "${var.app_name}-${var.app_namespace}-${var.tfenv} LOGGING EKS Secret Encryption Key"
  tags = {
    Name        = "${var.app_name}-${var.app_namespace}-${var.tfenv}-elasticstack-s3-key"
    Environment = var.tfenv
    Billingcustomer = var.billingcustomer
    Namespace = var.app_namespace
    Product = var.app_name
  }
}

module "log_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  # create_bucket = var.tfenv == "prod" ? true : false

  bucket        = "${var.app_name}-${var.app_namespace}-${var.tfenv}-elasticstack-logs"
  
  acl           = "log-delivery-write"
  force_destroy = var.tfenv == "prod" ? false : true

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = aws_kms_key.eks_logging.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

module "s3_elasticstack_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  # create_bucket = var.tfenv == "prod" ? true : false

  bucket        = "${var.app_name}-${var.app_namespace}-${var.tfenv}-elasticstack"
  
  acl           = "private"
  force_destroy = var.tfenv == "prod" ? false : true

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = aws_kms_key.eks_logging.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  logging = {
    target_bucket = module.log_bucket.this_s3_bucket_id
    target_prefix = "logs/"
  }

  lifecycle_rule = [
    {
      id      = "log"
      enabled = true

      tags = {
        rule      = "log"
        autoclean = "true"
      }

      transition = var.tfenv == "prod" ? [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 60
          storage_class = "GLACIER"
        },
        {
          days          = 150
          storage_class = "DEEP_ARCHIVE"
        }
      ] : [
        {
          days          = 30
          storage_class = "ONEZONE_IA"
        },
      ]

      expiration = {
        days = var.tfenv == "prod" ? 365 : 60
      }
    }
  ]
  
  tags = {
    Name        = "${var.app_name}-${var.app_namespace}-${var.tfenv}-logs"
    Environment = var.tfenv
    Billingcustomer = var.billingcustomer
    Description       = "Elasticstack Cluster-Application Logging"
    Product           = "Elasticstack"
    Namespace         = var.app_namespace
  }
}

##TODO: Migrate IAM USER to IAM ROLE

### IAM USER DEFINITION
module "iam_user" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "~> 3.0"

  name = "${var.app_name}-${var.app_namespace}-${var.tfenv}-elasticstack-s3-user"
  path = "/serviceaccounts/${var.app_name}/${var.app_namespace}/"

  create_iam_access_key = true
  create_iam_user_login_profile = false


  force_destroy = var.tfenv == "prod" ? true : false

  ## TODO: Setup PGP Encryption for Access KEY/SECRET provisioning
  # pgp_key = "keybase:test"

  password_reset_required = false  
}

### IAM POLICY DEFINITION
resource "aws_iam_policy" "s3_access_policy" {
    name = "${var.app_name}-${var.app_namespace}-${var.tfenv}-elasticstack-s3-policy"
    description = "Terraform Generated : ${var.app_name}-${var.app_namespace}-${var.tfenv}"

    path = "/serviceaccounts/${var.app_name}/${var.app_namespace}/"
    policy = data.aws_iam_policy_document.s3_policy_data.json
}

data "aws_iam_policy_document" "s3_policy_data" {
    statement {
        sid = "1"
        actions = [
            "s3:ListAccessPointsForObjectLambda",
            "s3:PutAnalyticsConfiguration",
            "s3:GetObjectVersionTagging",
            "s3:CreateBucket",
            "s3:ReplicateObject",
            "s3:GetObjectAcl",
            "s3:GetBucketObjectLockConfiguration",
            "s3:DeleteBucketWebsite",
            "s3:GetIntelligentTieringConfiguration",
            "s3:PutLifecycleConfiguration",
            "s3:GetObjectVersionAcl",
            "s3:PutBucketAcl",
            "s3:PutObjectTagging",
            "s3:DeleteObject",
            "s3:DeleteObjectTagging",
            "s3:GetBucketPolicyStatus",
            "s3:PutAccountPublicAccessBlock",
            "s3:GetObjectRetention",
            "s3:GetBucketWebsite",
            "s3:ListJobs",
            "s3:PutReplicationConfiguration",
            "s3:DeleteObjectVersionTagging",
            "s3:PutObjectLegalHold",
            "s3:GetObjectLegalHold",
            "s3:GetBucketNotification",
            "s3:PutBucketCORS",
            "s3:DeleteBucketPolicy",
            "s3:GetReplicationConfiguration",
            "s3:ListMultipartUploadParts",
            "s3:PutObject",
            "s3:GetObject",
            "s3:PutBucketNotification",
            "s3:PutBucketLogging",
            "s3:PutObjectVersionAcl",
            "s3:GetAnalyticsConfiguration",
            "s3:PutBucketObjectLockConfiguration",
            "s3:GetObjectVersionForReplication",
            "s3:CreateJob",
            "s3:GetLifecycleConfiguration",
            "s3:GetAccessPoint",
            "s3:GetInventoryConfiguration",
            "s3:GetBucketTagging",
            "s3:PutAccelerateConfiguration",
            "s3:DeleteObjectVersion",
            "s3:GetBucketLogging",
            "s3:ListBucketVersions",
            "s3:ReplicateTags",
            "s3:RestoreObject",
            "s3:ListBucket",
            "s3:GetAccelerateConfiguration",
            "s3:GetBucketPolicy",
            "s3:PutEncryptionConfiguration",
            "s3:GetEncryptionConfiguration",
            "s3:GetObjectVersionTorrent",
            "s3:AbortMultipartUpload",
            "s3:PutBucketTagging",
            "s3:GetBucketRequestPayment",
            "s3:DeleteBucketOwnershipControls",
            "s3:GetObjectTagging",
            "s3:GetMetricsConfiguration",
            "s3:GetBucketOwnershipControls",
            "s3:DeleteBucket",
            "s3:PutBucketVersioning",
            "s3:PutObjectAcl",
            "s3:GetBucketPublicAccessBlock",
            "s3:ListBucketMultipartUploads",
            "s3:PutBucketPublicAccessBlock",
            "s3:PutIntelligentTieringConfiguration",
            "s3:ListAccessPoints",
            "s3:PutMetricsConfiguration",
            "s3:PutBucketOwnershipControls",
            "s3:PutObjectVersionTagging",
            "s3:GetBucketVersioning",
            "s3:GetBucketAcl",
            "s3:BypassGovernanceRetention",
            "s3:PutInventoryConfiguration",
            "s3:ListStorageLensConfigurations",
            "s3:GetObjectTorrent",
            "s3:ObjectOwnerOverrideToBucketOwner",
            "s3:GetAccountPublicAccessBlock",
            "s3:PutBucketWebsite",
            "s3:ListAllMyBuckets",
            "s3:PutBucketRequestPayment",
            "s3:PutObjectRetention",
            "s3:GetBucketCORS",
            "s3:PutBucketPolicy",
            "s3:GetBucketLocation",
            "s3:ReplicateDelete",
            "s3:GetObjectVersion"
        ]
        resources = [
            "arn:aws:s3:::${var.app_name}-${var.app_namespace}-${var.tfenv}-elasticstack-logs/*",
            "arn:aws:s3:::${var.app_name}-${var.app_namespace}-${var.tfenv}-elasticstack-logs"
        ]
    }
}

resource "aws_iam_user_policy_attachment" "s3_attach" {
  user       = module.iam_user.this_iam_user_name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "aws_iam_policy" "kms_access_policy" {
    name = "${var.app_name}-${var.app_namespace}-${var.tfenv}-elasticstack-kms-s3-policy"
    description = "Terraform Generated : ${var.app_name}-${var.app_namespace}-${var.tfenv}"

    path = "/serviceaccounts/${var.app_name}/${var.app_namespace}/"
    policy = data.aws_iam_policy_document.kms_policy_data.json
}

data "aws_iam_policy_document" "kms_policy_data" {
  statement {
    sid = "2"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = [
      aws_kms_key.eks_logging.arn
    ]
  }
}

resource "aws_iam_user_policy_attachment" "kms_attach" {
  user       = module.iam_user.this_iam_user_name
  policy_arn = aws_iam_policy.kms_access_policy.arn
}