output "teleport_kube_agent_irsa_role" {
  value = module.teleport_kube_agent_irsa_role[0].iam_role_arn
}
output "teleport_kube_agent_trusted_role" {
  value = module.teleport_kube_agent_trusted_role[0].iam_role_arn
}
output "teleport_cluster_irsa_role" {
  value = module.teleport_cluster_irsa_role[*].iam_role_arn
}
