variable "gitlab_token" {
  description = "Gitlab Token"
}

variable "gitlab_namespace" {
  description = "Gitlab Namespace where K8s can be viewed and monitored at"
}

variable "eks" {
  description = "Pass along the module responses from parent EKS cluster configuration"
}

variable "cluster_environment_scope" {
  description = "Environment Scope that the cluster should cover according to Gitlab CI"
}

variable "tfenv" {}
variable "app_namespace" {}
variable "root_domain_name" {}