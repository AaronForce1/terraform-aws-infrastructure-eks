# Create a base domain for EKS Cluster
data "aws_route53_zone" "base_domain" {
  name = var.root_domain_name
}

resource "aws_route53_record" "eks_domain" {
  count = length(var.ingress_records)

  zone_id = data.aws_route53_zone.base_domain.id
  name    = var.ingress_records[count.index]
  type    = "A"

  alias {
    name                   = data.kubernetes_service.ingress_gateway.status[0].load_balancer[0].ingress[0].hostname
    zone_id                = data.aws_elb_hosted_zone_id.elb_zone_id.id
    evaluate_target_health = true
  }

  depends_on = [helm_release.nginx-controller]
}
data "kubernetes_service" "ingress_gateway" {
  metadata {
    name      = "nginx-controller"
    namespace = "ingress-nginx"
  }
}

data "aws_elb_hosted_zone_id" "elb_zone_id" {}


