module "iam-iam-role-for-service-accounts-eks" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.20.0"

  #  count = try(var.aws_installations.cert_manager, false) && var.aws_installations.route53_external_dns ? 1 : 0
  for_each  = var.iam-irsa
  role_name = try(each.value.role_name, "${var.app_name}-${var.app_namespace}-${var.tfenv}-${try(each.value.name, each.key)}")
  role_path = try(each.value.role_path, "/${var.app_name}/${var.app_namespace}/${var.tfenv}/")

  allow_self_assume_role = try(each.value.allow_self_assume_role, false)

  # Cert-manager
  attach_cert_manager_policy = each.key == "cert-manager" ? true : false
  cert_manager_hosted_zone_arns = lookup(var.route53_hosted_zone_arns, "route53_hosted_zone_arns", [
    "arn:aws:route53:::hostedzone/*"
  ])

  # cluster autoscaler
  attach_cluster_autoscaler_policy = each.key == "cluster-autoscaler" ? true : false
  cluster_autoscaler_cluster_names = try(each.value.cluster_autoscaler_cluster_names, [])

  # ebs csi
  attach_ebs_csi_policy = each.key == "AmazonEKS-CSI_Driver-role" ? true : false
  ebs_csi_kms_cmk_ids   = try(each.value.ebs_csi_kms_cmk_ids, [])

  # efs csi
  attach_efs_csi_policy = try(each.value.attach_efs_csi_policy, false)

  # external-dns
  attach_external_dns_policy = each.key == "external-dns" ? true : false
  external_dns_hosted_zone_arns = lookup(var.route53_hosted_zone_arns, "route53_hosted_zone_arns", [
    "arn:aws:route53:::hostedzone/*"
  ])

  # external-secrets
  attach_external_secrets_policy = each.key == "external-secrets-policy" ? true : false
  external_secrets_kms_key_arns = try(each.value.external_secrets_kms_key_arns, [
    "arn:aws:kms:::key/*"
  ])
  external_secrets_secrets_manager_arns = try(each.value.external_secrets_secrets_manager_arns, [
    "arn:aws:secretsmanager:::secret:*"
  ])
  external_secrets_ssm_parameter_arns = try(each.value.external_secrets_ssm_parameter_arns, [
    "arn:aws:ssm:::parameter/*"
  ])

  # karpenter
  attach_karpenter_controller_policy = each.key == "karpenter" ? true : false
  karpenter_controller_cluster_name  = try(each.value.karpenter_controller_cluster_name, "*")
  karpenter_controller_node_iam_role_arns = try(each.value.karpenter_controller_node_iam_role_arns, [
    "*"
  ])
  karpenter_sqs_queue_arn = try(each.value.karpenter_sqs_queue_arn, null)
  karpenter_tag_key       = try(each.value.karpenter_tag_key, "karpenter.sh/discovery")


  oidc_providers = {
    main = {
      provider_arn = var.oidc_provider_arn
      namespace_service_accounts = try(each.value.attach_efs_csi_policy, false) == true ? [
        "${each.value.namespace}:${each.value.service_account_ebs}",
        "${each.value.namespace}:${each.value.service_account_efs}"
      ] : ["${each.value.namespace}:${each.value.service_account}"]
    }
  }

  ## Additional policy arns to be added:

  role_policy_arns = merge(
    try(each.value.role_policy_arns, {}),
    try(each.value.custom_policy, "") != "" ? {
      custom_policy_arn = module.iam_iam-policy[each.key].arn
    } : {}
  )
}

# Module if there's any custom iam policy to be added to the irsa role
module "iam_iam-policy" {
  source        = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version       = "5.20.0"
  for_each      = var.iam-irsa
  create_policy = try(each.value.custom_policy, "") == "" ? false : true
  description   = try("${each.value.role_name}-irsa-policy", "${var.app_name}-${var.app_namespace}-${var.tfenv}-${try("${each.value.role_name}-irsa-policy", "${each.key}-irsa-policy")}")
  name          = try("${each.key}-irsa-policy", null)
  policy        = try(each.value.custom_policy, "") == "" ? "" : jsonencode(each.value.custom_policy)
}
