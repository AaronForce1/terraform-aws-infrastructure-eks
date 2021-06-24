locals {
  kubernetes_tags = {
      Name                                                                          = "${var.app_name}-${var.app_namespace}-${var.tfenv}"
      Environment                                                                   = var.tfenv
      billingcustomer                                                               = var.billingcustomer
      Namespace                                                                     = var.app_namespace
      Product                                                                       = var.app_name
      Version                                                                       = data.local_file.infrastructure-terraform-eks-version.content
      infrastructure-terraform-eks                                                  = data.local_file.infrastructure-terraform-eks-version.content
      "k8s.io/cluster-autoscaler/enabled"                                           = true
      "k8s.io/cluster-autoscaler/${var.app_name}-${var.app_namespace}-${var.tfenv}" = true
  }
  additional_kubernetes_tags = {
      Name                         = "${var.app_name}-${var.app_namespace}-${var.tfenv}"  
      Environment                  = var.tfenv
      billingcustomer              = var.billingcustomer
      Namespace                    = var.app_namespace
      Product                      = var.app_name
      infrastructure-terraform-eks = data.local_file.infrastructure-terraform-eks-version.content
  }


  default_node_group = {
    core = {
      desired_capacity = var.instance_desired_size
      max_capacity     = var.instance_max_size
      min_capacity     = var.instance_min_size
      instance_type   = var.instance_type
      key_name         = var.node_key_name
      public_ip        = var.node_public_ip
      create_launch_template = var.create_launch_template
      disk_size        = "50"
      k8s_labels = {
        Environment = var.tfenv
      }
      tags = local.kubernetes_tags
      additional_tags = local.additional_kubernetes_tags
    }
  }
}