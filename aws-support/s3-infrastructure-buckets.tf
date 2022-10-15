module "aws_s3_infra_support_buckets" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.4"

  for_each = {
    for bucket in var.eks_infrastructure_support_buckets : bucket.name => bucket
  }

  bucket = "${var.name_prefix}-${each.value.name}"

  acl           = each.value.bucket_acl
  force_destroy = var.tfenv == "prod" ? false : true

  block_public_policy     = true
  block_public_acls       = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = each.value.aws_kms_key_id
        sse_algorithm     = "aws:kms"
      }
    }
  }

  versioning = {
    status = each.value.versioning
  }

  lifecycle_rule = each.value.lifecycle_rules

  tags = var.tags
}

## IAM Role and Policy
data "aws_iam_policy_document" "aws_s3_infra_support_bucket_iam_policy_document" {
  for_each = {
    for bucket in var.eks_infrastructure_support_buckets : bucket.name => bucket
  }

  statement {
    actions = ["s3:*"]
    resources = [
      "${module.aws_s3_infra_support_buckets[each.value.name].s3_bucket_arn}/*",
      module.aws_s3_infra_support_buckets[each.value.name].s3_bucket_arn
    ]
  }

  statement {
    actions = [
      "kms:GenerateDataKey",
      "kms:Encrypt",
      "kms:Decrypt"
    ]
    resources = [
      each.value.aws_kms_key_id != null ? each.value.aws_kms_key_id : var.eks_infrastructure_kms_arn
    ]
  }
}

resource "aws_iam_policy" "aws_s3_infra_support_bucket_iam_policies" {
  for_each = {
    for bucket in var.eks_infrastructure_support_buckets : bucket.name => bucket
  }

  name        = "${var.app_name}-${var.app_namespace}-${var.tfenv}-s3-custom-policy-${each.value.name}"
  path        = "/${var.app_name}/${var.app_namespace}/${var.tfenv}/"
  description = "EKS S3-custom-policy-${each.value.name} policy: ${var.app_name}-${var.app_namespace}-${var.tfenv}"
  policy      = data.aws_iam_policy_document.aws_s3_infra_support_bucket_iam_policy_document[each.value.name].json
  tags        = var.tags
}


module "aws_s3_infra_support_bucket_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "4.24"

  for_each = {
    for bucket in var.eks_infrastructure_support_buckets : bucket.name => bucket

  }

  create_role = true

  role_name = "${var.app_name}-${var.app_namespace}-${var.tfenv}-s3-custom-role-${each.value.name}"

  role_path    = "/${var.app_name}/${var.app_namespace}/${var.tfenv}/"
  provider_url = replace(var.oidc_url, "https://", "")

  role_policy_arns = [aws_iam_policy.aws_s3_infra_support_bucket_iam_policies[each.value.name].arn]

  oidc_fully_qualified_subjects = [join("", concat(["system:serviceaccount:"], each.value.k8s_namespace_service_account_access))]

  tags = var.tags
}

locals {
  role_policy_attachments = distinct(flatten([
    for s3 in var.eks_infrastructure_support_buckets : [
      for role_name in var.eks_managed_node_group_roles : {
        s3        = s3
        role_name = role_name.value
      }
    ]
    if s3.eks_node_group_access
  ]))
}

resource "aws_iam_role_policy_attachment" "additional" {
  for_each = {
    for role_attachment in local.role_policy_attachments : "${role_attachment.s3.name}-${role_attachment.role_name}" => role_attachment
  }

  policy_arn = resource.aws_iam_policy.aws_s3_infra_support_bucket_iam_policies[each.value.s3.name].arn
  role       = each.value.role_name
}


## ROLE THANOS-SLAVE
data "aws_eks_cluster" "eks_slave" {
  count = var.thanos_slave_role ? 1 : 0
  name  = var.eks_slave
}

module "aws_s3_thanos_slave_bucket_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "4.24"

  for_each = {
    for bucket in var.eks_infrastructure_support_buckets : bucket.name => bucket if length(data.aws_eks_cluster.eks_slave) == 1
  }

  create_role = var.thanos_slave_role ? true : false

  role_name = "${var.app_name}-${var.app_namespace}-${var.tfenv}-s3-custom-role-thanos-slave"

  role_path    = "/${var.app_name}/${var.app_namespace}/${var.tfenv}/"
  
  provider_url = replace(data.aws_eks_cluster.eks_slave[0].identity[0].oidc[0].issuer, "https://", "")


  role_policy_arns = [aws_iam_policy.aws_s3_infra_support_bucket_iam_policies[lookup(each.value, "name", "${var.name_prefix}-${var.name_prefix}-thanos")].arn]


  oidc_fully_qualified_subjects = ["system:serviceaccount:prometheus-stack:thanos-prometheus"]

  tags = var.tags
}
