output "kubecfg" {
  value = module.eks.kubeconfig
}
output "kubernetes-cluster-certificate-authority-data" {
  value = module.eks.cluster_certificate_authority_data
}

output "kubernetes-cluster-id" {
  value = module.eks.cluster_id
}

output "kubernetes-cluster-endpoint" {
  value = module.eks.cluster_endpoint
}