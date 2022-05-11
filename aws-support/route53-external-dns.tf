module "external_dns_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "4.24"

  count = var.aws_installations.route53_external_dns ? 1 : 0

  role_name = "external-dns"
  role_path = "/${var.app_name}/${var.app_namespace}/${var.tfenv}/"

  attach_external_dns_policy    = true
  external_dns_hosted_zone_arns = [var.route53_hosted_zone_arn]

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["external-dns:external-dns"]
    }
  }
}

