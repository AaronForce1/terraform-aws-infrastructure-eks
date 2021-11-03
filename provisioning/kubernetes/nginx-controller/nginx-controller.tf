resource "helm_release" "nginx-controller" {
  name       = "nginx-controller"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart               = "ingress-nginx"
  version             = "4.0.6"
  namespace           = "ingress-nginx"
  create_namespace    = true
  force_update        = true
  recreate_pods       = true
  verify              = false
  disable_openapi_validation = true
 
  values = [yamlencode({
    "controller": {
      "service": {
	    "annotations": {
		  "service.beta.kubernetes.io/aws-load-balancer-backend-protocol": "tcp"
		  "service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled": "true"
		  "service.beta.kubernetes.io/aws-load-balancer-type": "nlb"
		  "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags": "Environment=${var.tfenv},Billingcustomer=${var.billingcustomer},Namespace=${var.app_namespace},Product=${var.app_name},Version=${var.infrastructure_eks_terraform_version},infrastructure-eks-terraform=${var.infrastructure_eks_terraform_version}"
		}
		"externalTrafficPolicy": "Local"
	  }
	  "replicaCount": "${var.tfenv == "prod" ? 3 : 1}"
	  "autoscaling": {
	    "enabled": true
		"minReplicas": 1
		"maxReplicas": 6
		"targetCPUUtilizationPercentage": 70
		"targetMemoryUtilizationPercentage": 70
	  }
	  "metrics": {
		"enabled": true
	  }
	}
  })]
}
