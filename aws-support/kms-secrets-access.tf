## IAM Role for external-secrets
data "aws_iam_policy_document" "external_secrets" {
  count = var.aws_installations.kms_secrets_access ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "kms:GetPublicKey",
      "kms:Decrypt",
      "kms:ListKeyPolicies",
      "secretsmanager:DescribeSecret",
      "kms:ListRetirableGrants",
      "ssm:GetParameterHistory",
      "kms:GetKeyPolicy",
      "kms:ListResourceTags",
      "ssm:GetParameters",
      "ssm:GetParameter",
      "kms:ListGrants",
      "secretsmanager:ListSecretVersionIds",
      "kms:GetParametersForImport",
      "kms:DescribeCustomKeyStores",
      "kms:ListKeys",
      "secretsmanager:GetSecretValue",
      "kms:GetKeyRotationStatus",
      "kms:Encrypt",
      "ssm:DescribeParameters",
      "kms:ListAliases",
      "kms:DescribeKey",
      "ssm:GetParametersByPath",
      "secretsmanager:ListSecrets",
    ]
    ## TODO: Restrict resources to cluster-associated only.
    resources = ["*"]
  }
}

resource "aws_iam_policy" "external_secrets" {
  count = var.aws_installations.kms_secrets_access ? 1 : 0

  name        = "${var.app_name}-${var.app_namespace}-${var.tfenv}-external-secrets-policy"
  path        = "/${var.app_name}/${var.app_namespace}/${var.tfenv}"
  description = "EKS External Secrets Policy allowing SSM and KMS access: ${var.app_name}-${var.app_namespace}-${var.tfenv}"
  policy      = data.aws_iam_policy_document.external_secrets[0].json
  tags        = var.tags
}


module "external_secrets_irsa_role" {
  count = var.aws_installations.kms_secrets_access ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "4.24"

  role_name = "${var.app_name}-${var.app_namespace}-${var.tfenv}-external_secrets"
  role_path = "/${var.app_name}/${var.app_namespace}/${var.tfenv}/"

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["external-secrets:external-secrets"]
    }
  }

  # role_policy_arns = [
  #   aws_iam_policy.external_secrets[0].arn
  # ]
}
