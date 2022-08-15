variable "app_name" {}
variable "app_namespace" {}
variable "tfenv" {}
variable "cluster_oidc_issuer_url" {}
variable "aws_region" {}

### AWS Cluster Autoscaling 
variable "scale_down_util_threshold" {
  description = "AWS Autoscaling, scale_down_util_threshold (AWS defaults to 0.5, but raising that to 0.7 to be a tad more aggressive with scaling back)"
  default     = 0.7
}

variable "skip_nodes_with_local_storage" {
  description = "AWS Autoscaling, skip_nodes_with_local_storage (AWS defaults to true, also modifying to false for more scaling back)"
  default     = "false"
}

variable "skip_nodes_with_system_pods" {
  description = "AWS Autoscaling, skip_nodes_with_system_pods (AWS defaults to true, but here default to false, again to be a little bit more aggressive with scaling back)"
  default     = "false"
}

variable "cordon_node_before_term" {
  description = "AWS Autoscaling, cordon_node_before_term (AWS defaults to false, but setting it to true migth give a more friendly removal process)"
  default     = "true"
}

variable "tags" {}