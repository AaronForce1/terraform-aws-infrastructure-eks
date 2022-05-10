# data "aws_iam_policy_document" "cert_manager" {
#   count = try(var.aws_installations.cert_manager, false) && var.aws_installations.route53_external_dns ? 1 : 0

#   statement {
#     actions   = ["route53:GetChange"]
#     resources = ["arn:aws:route53:::change/*"]
#   }

#   statement {
#     actions = [
#       "route53:ChangeResourceRecordSets",
#       "route53:ListResourceRecordSets",
#     ]
#     resources = [var.route53_hosted_zone_arn]
#   }
# }

# resource "aws_iam_policy" "cert_manager" {
#   count = try(var.aws_installations.cert_manager, false) && var.aws_installations.route53_external_dns ? 1 : 0

#   name        = "${var.app_name}-${var.app_namespace}-${var.tfenv}-cert-manager-policy"
#   path        = "/${var.app_namespace}/${var.tfenv}"
#   description = "CertManager policy for managing Route53 records: ${var.app_name}-${var.app_namespace}-${var.tfenv}"
#   policy      = data.aws_iam_policy_document.cert_manager[0].json
#   tags        = var.tags
# }

# BUG: https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest#%E2%84%B9%EF%B8%8F-error-invalid-for_each-argument-
# WORKAROUND: terraform apply -target=aws_iam_policy.cert_manager
module "cert_manager_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "4.24"

  # depends_on = [
  #   resource.aws_iam_policy.cert_manager
  # ]

  count = try(var.aws_installations.cert_manager, false) && var.aws_installations.route53_external_dns ? 1 : 0

  role_name = "cert-manager"
  role_path = "/${var.app_namespace}/${var.tfenv}"

  attach_cert_manager_policy = true
  cert_manager_hosted_zone_arns = [var.route53_hosted_zone_arn]

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["cert-manager:cert-manager"]
    }
  }

  # role_policy_arns = [
  #   aws_iam_policy.cert_manager[0].arn
  # ]
}