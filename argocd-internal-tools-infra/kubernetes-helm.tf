module "argocd" {
  source = "./provisioning/kubernetes/argocd"
  count  = var.helm_installations.argocd ? 1 : 0

  chart_version                     = var.helm_configurations.argocd.chart_version
  root_domain_name                  = var.cluster_root_domain.name
  operator_domain_name              = var.operator_domain_name
  slave_domain_name                 = var.slave_domain_name
  hosted_zone_id                    = var.hosted_zone_id #aws_route53_zone.hosted_zone[0].zone_id
  kms_key_id                        = data.aws_kms_key.kms.id
  custom_manifest                   = var.helm_configurations.argocd
  repository_secrets                = var.helm_configurations.argocd.repository_secrets
  credential_templates              = var.helm_configurations.argocd.credential_templates
  registry_secrets                  = var.helm_configurations.argocd.registry_secrets
  generate_plugin_repository_secret = var.helm_configurations.argocd.generate_plugin_repository_secret
  additionalProjects                = var.helm_configurations.argocd.additionalProjects
}

data "aws_kms_key" "kms" {
  key_id = var.eks_infrastructure_kms_arn
}
