## TODO: ADD COMPATIBILITY FOR PRIVATE EKS CLUSTERS
resource "aws_route53_zone" "hosted_zone" {
  count = try(var.cluster_root_domain.create ? 1 : 0, 0)
  name  = var.cluster_root_domain.name
  tags  = local.base_tags
}