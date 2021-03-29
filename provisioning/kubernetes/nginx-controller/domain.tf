# Create a base domain for EKS Cluster
data "aws_route53_zone" "base_domain" {
  name = var.root_domain_name
}

# resource "aws_route53_record" "eks_domain" {
#   zone_id = data.aws_route53_zone.base_domain.id
#   name    = "${var.app_namespace}-${var.tfenv}.${var.root_domain_name}"
#   type    = "A"

#   alias {
#     name                   = data.kubernetes_service.ingress_gateway.status.0.load_balancer.0.ingress.0.hostname
#     zone_id                = data.aws_elb_hosted_zone_id.elb_zone_id.id
#     evaluate_target_health = true
#   }

#   depends_on = [helm_release.nginx-controller]
# }
# data "kubernetes_service" "ingress_gateway" {
#   metadata {
#     name = "nginx-controller"
#   }
# }

# variable "ingress_gateway_annotations" {
#   description = "Sets up standard HTTPS -> HTTP Ingress Controllers"
#   default = { 
#     "controller.service.httpPort.targetPort"                                                                    = "http",
#     "controller.service.httpsPort.targetPort"                                                                   = "http",
#     "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-backend-protocol"        = "http",
#     "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-ports"               = "https",
#     "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-connection-idle-timeout" = "60",
#     "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"                    = "elb"
#   }
# }


# resource "aws_acm_certificate" "eks_domain_cert" {
#   domain_name               = "eks-${var.app_namespace}-${var.tfenv}.${var.root_domain_name}"
#   subject_alternative_names = ["*.eks-${var.app_namespace}-${var.tfenv}.${var.root_domain_name}"]
#   validation_method         = "DNS"

#   tags = {
#     Name                                        = "eks-${var.app_namespace}-${var.tfenv}.${var.root_domain_name}"
#     Environment                                 = var.tfenv
#     Terraform                                   = "true"
#     Namespace                                   = var.app_namespace
#     billingcustomer                             = var.billingcustomer
#   }
# }
# resource "aws_route53_record" "eks_domain_cert_validation_dns" {
#   name    = tolist(aws_acm_certificate.eks_domain_cert.domain_validation_options).0.resource_record_name
#   type    = tolist(aws_acm_certificate.eks_domain_cert.domain_validation_options).0.resource_record_type
#   zone_id = data.aws_route53_zone.base_domain.id
#   records = [tolist(aws_acm_certificate.eks_domain_cert.domain_validation_options).0.resource_record_value]
#   ttl     = 60
# }
# resource "aws_acm_certificate_validation" "eks_domain_cert_validation" {
#   certificate_arn         = aws_acm_certificate.eks_domain_cert.arn
#   validation_record_fqdns = [aws_route53_record.eks_domain_cert_validation_dns.fqdn]
# }

# Ingress Controller
# resource "helm_release" "ingress_gateway" {
#   name       = "nginx-ingress"
#   chart      = "nginx-ingress"
#   repository = "https://helm.nginx.com/stable"
#   version    = "0.5.2"

#   dynamic "set" {
#     for_each = var.ingress_gateway_annotations

#     content {
#       name  = set.key
#       value = set.value
#       type  = "string"
#     }
#   }

#   set {
#     name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-cert"
#     value = aws_acm_certificate.eks_domain_cert.id
#   }
# }

data "aws_elb_hosted_zone_id" "elb_zone_id" {}


