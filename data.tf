data "aws_caller_identity" "current" {}
data "local_file" "infrastructure-terraform-eks-version" {
  filename = "${path.module}/VERSION"
}
data "aws_route53_zone" "cluster_domains" {
  for_each = {
    for domain in local.cluster_domains : domain => domain
  }
  name = each.value
}