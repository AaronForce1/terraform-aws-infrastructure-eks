resource "kubectl_manifest" "teleport-dev-role-binding" {
  for_each = {
    for role in var.kubernetes_access_controls : role.value_file => role
  }
  yaml_body = each.value.value_file
}