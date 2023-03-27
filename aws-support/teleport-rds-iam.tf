## IAM Role and policies for teleport

data "aws_caller_identity" "current" {}
locals {
  account_id = data.aws_caller_identity.current.account_id
}
output "account_id" {
  value = local.account_id
}

data "aws_iam_policy_document" "aws_rds_iam_policy_document_teleport" {
  statement {
    effect    = "Allow"
    actions   = ["rds-db:connect"]
    resources = ["arn:aws:rds-db:${var.aws_region}:${local.account_id}:dbuser:*/*"]
  }
}

resource "aws_iam_policy" "aws_rds_iam_policy_teleport" {
  name        = "${var.app_name}-${var.app_namespace}-${var.tfenv}-teleport"
  path        = "/${var.app_name}/${var.app_namespace}/${var.tfenv}/"
  description = "TELEPORT RDS IAM policy: ${var.app_name}-${var.app_namespace}-${var.tfenv}-teleport"
  policy      = data.aws_iam_policy_document.aws_rds_iam_policy_document_teleport.json
  tags        = var.tags
}

### 
data "aws_iam_policy_document" "aws_rds_iam_role_teleport_trusted_entity" {

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider_arn, "/^(.*provider/)/", "")}:sub"
      values   = [for sa in var.aws_installations.teleport_rds_iam.namespace_service_accounts : "system:serviceaccount:${sa}"]
    }

    # https://aws.amazon.com/premiumsupport/knowledge-center/eks-troubleshoot-oidc-and-irsa/?nc1=h_ls
    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider_arn, "/^(.*provider/)/", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "aws_rds_iam_role_teleport" {
  name               = "${var.app_name}-${var.app_namespace}-${var.tfenv}-teleport"
  path               = "/${var.app_name}/${var.app_namespace}/${var.tfenv}/"
  description        = "TELEPORT RDS ROLE: ${var.app_name}-${var.app_namespace}-${var.tfenv}-teleport"
  assume_role_policy = data.aws_iam_policy_document.aws_rds_iam_role_teleport_trusted_entity.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "aws_rds_iam_role_policy_teleport_attach" {
  role       = aws_iam_role.aws_rds_iam_role_teleport.name
  policy_arn = aws_iam_policy.aws_rds_iam_policy_teleport.arn
}