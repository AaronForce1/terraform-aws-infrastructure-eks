data "aws_caller_identity" "current" {}
data "aws_route53_zone" "cluster_domains" {
  for_each = {
    for domain in local.cluster_domains : domain => domain
  }
  name = each.value
}
