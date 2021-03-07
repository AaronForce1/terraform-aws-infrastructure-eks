output "env-dynamic-url" {
  value = module.eks.cluster_endpoint
}

output "kubecfg" {
  value = module.eks.kubeconfig
}