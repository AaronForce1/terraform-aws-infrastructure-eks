output "irsa_role_arn" {
  value = values(module.iam-iam-role-for-service-accounts-eks)[*].iam_role_arn
}
output "policy_arn" {
  value = values(module.iam_iam-policy)[*].arn
}
