##TODO: Migrate IAM USER to IAM ROLE

### IAM USER DEFINITION
module "iam_user" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "~> 4.0"

  name = "gitlab-runner-${var.app_namespace}-${var.tfenv}-cache-user"
  path = "/serviceaccounts/${var.app_namespace}/${var.tfenv}/"

  create_iam_access_key         = true
  create_iam_user_login_profile = false

  force_destroy = var.tfenv == "prod" ? true : false

  ## TODO: Setup PGP Encryption for Access KEY/SECRET provisioning
  # pgp_key = "keybase:test"

  password_reset_required = false

  tags = {
    description     = "Terraform Generated : ${var.app_namespace}-${var.tfenv}"
    Name            = "gitlab-runner-${var.app_namespace}-${var.tfenv}-cache-user"
    Environment     = var.tfenv
  }
}

### IAM POLICY DEFINITION
resource "aws_iam_policy" "s3_access_policy" {

  name        = "gitlab-runner-${var.app_namespace}-${var.tfenv}-cache-user-policy"
  description = "Terraform Generated : ${var.app_namespace}-${var.tfenv}"

  path   = "/serviceaccounts/${var.app_namespace}/${var.tfenv}/"
  policy = data.aws_iam_policy_document.policy_data.json
}

data "aws_iam_policy_document" "policy_data" {
  statement {
    sid = "1"
    actions = [
      "s3:PutAnalyticsConfiguration",
      "s3:GetObjectVersionTagging",
      "s3:CreateBucket",
      "s3:ReplicateObject",
      "s3:GetObjectAcl",
      "s3:DeleteBucketWebsite",
      "s3:PutLifecycleConfiguration",
      "s3:GetObjectVersionAcl",
      "s3:PutObjectTagging",
      "s3:DeleteObject",
      "s3:DeleteObjectTagging",
      "s3:GetBucketWebsite",
      "s3:PutReplicationConfiguration",
      "s3:DeleteObjectVersionTagging",
      "s3:GetBucketNotification",
      "s3:PutBucketCORS",
      "s3:GetReplicationConfiguration",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
      "s3:GetObject",
      "s3:PutBucketNotification",
      "s3:PutBucketLogging",
      "s3:GetAnalyticsConfiguration",
      "s3:GetObjectVersionForReplication",
      "s3:GetLifecycleConfiguration",
      "s3:GetInventoryConfiguration",
      "s3:GetBucketTagging",
      "s3:PutAccelerateConfiguration",
      "s3:DeleteObjectVersion",
      "s3:GetBucketLogging",
      "s3:ListBucketVersions",
      "s3:ReplicateTags",
      "s3:RestoreObject",
      "s3:GetAccelerateConfiguration",
      "s3:GetBucketPolicy",
      "s3:GetObjectVersionTorrent",
      "s3:AbortMultipartUpload",
      "s3:PutBucketTagging",
      "s3:GetBucketRequestPayment",
      "s3:GetObjectTagging",
      "s3:GetMetricsConfiguration",
      "s3:DeleteBucket",
      "s3:PutBucketVersioning",
      "s3:PutObjectAcl",
      "s3:ListBucketMultipartUploads",
      "s3:PutMetricsConfiguration",
      "s3:PutObjectVersionTagging",
      "s3:GetBucketVersioning",
      "s3:GetBucketAcl",
      "s3:PutInventoryConfiguration",
      "s3:GetObjectTorrent",
      "s3:PutBucketWebsite",
      "s3:PutBucketRequestPayment",
      "s3:GetBucketCORS",
      "s3:GetBucketLocation",
      "s3:ReplicateDelete",
      "s3:GetObjectVersion",
      "s3:ListBucketByTags",
      "s3:ListBucket",
    ]
    resources = [
      "arn:aws:s3:::gitlab-runner-${var.app_namespace}-${var.tfenv}-cache-user/*",
      "arn:aws:s3:::gitlab-runner-${var.app_namespace}-${var.tfenv}-cache-user-policy"
    ]
  }
}

## IAM POLICY ATTACHMENT
resource "aws_iam_user_policy_attachment" "s3_attach" {

  user       = module.iam_user.this_iam_user_name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}