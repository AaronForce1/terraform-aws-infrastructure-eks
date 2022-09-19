module "aws_s3_infra_support_buckets" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.2"

  count = length(var.eks_infrastructure_support_buckets)

  bucket = "${var.name_prefix}-${var.eks_infrastructure_support_buckets[count.index].name}"

  acl           = var.eks_infrastructure_support_buckets[count.index].bucket_acl
  force_destroy = var.tfenv == "prod" ? false : true

  block_public_policy     = true
  block_public_acls       = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = var.eks_infrastructure_support_buckets[count.index].aws_kms_key_id
        sse_algorithm     = "aws:kms"
      }
    }
  }

  versioning = {
    status = var.eks_infrastructure_support_buckets[count.index].versioning
  }

  lifecycle_rule = var.eks_infrastructure_support_buckets[count.index].lifecycle_rules

  tags = var.tags
}

## IAM Role for Loki
data "aws_iam_policy_document" "aws_s3_infra_support_bucket_iam_policy_document" {
  count = length(var.eks_infrastructure_support_buckets)
  statement {
    actions = ["s3:*"]
    resources = [
      "${module.aws_s3_infra_support_buckets[count.index].s3_bucket_arn}/*",
      module.aws_s3_infra_support_buckets[count.index].s3_bucket_arn
    ]
  }

  statement {
    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt"
    ]
    resources = [
      var.eks_infrastructure_support_buckets[count.index].aws_kms_key_id != null ? var.eks_infrastructure_support_buckets[count.index].aws_kms_key_id : var.eks_infrastructure_kms_arn
    ]
  }
}

resource "aws_iam_policy" "aws_s3_infra_support_bucket_iam_policies" {
  count = length(var.eks_infrastructure_support_buckets)

  name        = "${var.app_name}-${var.app_namespace}-${var.tfenv}-s3-custom-policy-${var.eks_infrastructure_support_buckets[count.index].name}"
  path        = "/${var.app_name}/${var.app_namespace}/${var.tfenv}/"
  description = "EKS S3-custom-policy-${var.eks_infrastructure_support_buckets[count.index].name} policy: ${var.app_name}-${var.app_namespace}-${var.tfenv}"
  policy      = data.aws_iam_policy_document.aws_s3_infra_support_bucket_iam_policy_document[count.index].json
  tags        = var.tags
}


module "aws_s3_infra_support_bucket_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "4.24"
  
  count = length(var.eks_infrastructure_support_buckets)
  create_role = true
  
  role_name = "${var.app_name}-${var.app_namespace}-${var.tfenv}-s3-custom-role-${var.eks_infrastructure_support_buckets[count.index].name}"
  
  role_path    = "/${var.app_name}/${var.app_namespace}/${var.tfenv}/"
  provider_url = replace(var.oidc_url, "https://", "")
  
  role_policy_arns = [aws_iam_policy.aws_s3_infra_support_bucket_iam_policies[count.index].arn]
  
  oidc_fully_qualified_subjects = [join("", concat(["system:serviceaccount:"], "${var.eks_infrastructure_support_buckets[count.index].k8s_namespace_service_account_access}"))]
  
  tags = var.tags
}
