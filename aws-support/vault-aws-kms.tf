## IAM Role for external-secrets
data "aws_iam_policy_document" "vault_aws_kms" {
  count = try(var.aws_installations.vault_aws_kms.enabled, false) ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey",
    ]
    resources = [
      var.eks_infrastructure_kms_arn
    ]
  }
}

resource "aws_iam_policy" "vault_aws_kms" {
  count = try(var.aws_installations.vault_aws_kms.enabled, false) ? 1 : 0

  name        = "${var.app_name}-${var.app_namespace}-${var.tfenv}-vault-policy"
  path        = "/${var.app_name}/${var.app_namespace}/${var.tfenv}/"
  description = "EKS Vault Policy allowing KMS access: ${var.app_name}-${var.app_namespace}-${var.tfenv}"
  policy      = data.aws_iam_policy_document.vault_aws_kms[0].json
  tags        = var.tags
}

### 
data "aws_iam_policy_document" "vault_aws_kms_trusted_entity" {
  count = try(var.aws_installations.vault_aws_kms.enabled, false) ? 1 : 0

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
      values   = [for sa in var.aws_installations.vault_aws_kms.namespace_service_accounts : "system:serviceaccount:${sa}"]
    }

    # https://aws.amazon.com/premiumsupport/knowledge-center/eks-troubleshoot-oidc-and-irsa/?nc1=h_ls
    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider_arn, "/^(.*provider/)/", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "vault_aws_kms" {
  count = try(var.aws_installations.vault_aws_kms.enabled, false) ? 1 : 0

  name        = "${var.app_name}-${var.app_namespace}-${var.tfenv}-vault"
  path        = "/${var.app_name}/${var.app_namespace}/${var.tfenv}/"

  assume_role_policy    = data.aws_iam_policy_document.vault_aws_kms_trusted_entity[0].json
  force_detach_policies = true

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "vault_aws_kms" {
  count = try(var.aws_installations.vault_aws_kms.enabled, false) ? 1 : 0

  role       = aws_iam_role.vault_aws_kms[0].name
  policy_arn = aws_iam_policy.vault_aws_kms[0].arn
}