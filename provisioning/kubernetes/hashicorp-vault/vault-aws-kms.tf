resource "aws_kms_key" "vault" {
  count = var.enable_aws_vault_unseal ? 1 : 0

  description             = "${var.app_name}-${var.app_namespace}-${var.tfenv} VAULT EKS Unseal Key"
  enable_key_rotation     = true
  deletion_window_in_days = 10

  tags = var.tags

}

resource "aws_kms_alias" "vault" {
  count = var.enable_aws_vault_unseal ? 1 : 0

  name          = "alias/${var.app_name}-${var.app_namespace}-${var.tfenv}-vault-eks"
  target_key_id = aws_kms_key.vault[0].key_id
}

##TODO: Migrate IAM USER to IAM ROLE
##      https://github.com/hashicorp/vault-guides/blob/master/operations/aws-kms-unseal/terraform-aws/instance-profile.tf
##TODO: Migrate to a global service account user for non-application EKS softwre components

### IAM USER DEFINITION
module "iam_user" {
  count = var.enable_aws_vault_unseal ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "~> 4.24"

  name = "${var.app_name}-${var.app_namespace}-${var.tfenv}-eks-serviceaccount-user"
  path = "/serviceaccounts/${var.app_name}/${var.app_namespace}/"

  create_iam_access_key         = true
  create_iam_user_login_profile = false


  force_destroy = var.tfenv == "prod" ? true : false

  ## TODO: Setup PGP Encryption for Access KEY/SECRET provisioning
  # pgp_key = "keybase:test"

  password_reset_required = false
}

### IAM POLICY DEFINITION
resource "aws_iam_policy" "kms_access_policy" {
  count = var.enable_aws_vault_unseal ? 1 : 0

  name        = "${var.app_name}-${var.app_namespace}-${var.tfenv}-vault-kms-unseal-policy"
  description = "Terraform Generated : ${var.app_name}-${var.app_namespace}-${var.tfenv}"

  path   = "/serviceaccounts/${var.app_name}/${var.app_namespace}/"
  policy = data.aws_iam_policy_document.kms_policy_data.json

  tags = var.tags
}

data "aws_iam_policy_document" "kms_policy_data" {
  depends_on = [
    aws_kms_key.vault
  ]
  statement {
    sid    = "2"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey",
    ]
    resources = var.enable_aws_vault_unseal ? [
      aws_kms_key.vault[0].arn
    ] : []
  }
}

resource "aws_iam_user_policy_attachment" "kms_policy_attach" {
  count = var.enable_aws_vault_unseal ? 1 : 0

  user       = module.iam_user[0].iam_user_name
  policy_arn = aws_iam_policy.kms_access_policy[0].arn
}

resource "kubernetes_secret" "kms_iam_user" {
  count = var.enable_aws_vault_unseal ? 1 : 0
  metadata {
    name      = "${var.app_name}-${var.app_namespace}-${var.tfenv}-vault-kms-credentials"
    namespace = "hashicorp"
  }

  data = {
    AWS_ACCESS_KEY_ID     = module.iam_user[0].iam_access_key_id
    AWS_SECRET_ACCESS_KEY = module.iam_user[0].iam_access_key_secret
  }

  type = "generic"
}
