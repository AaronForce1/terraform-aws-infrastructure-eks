resource "kubectl_manifest" "teleport-cluster-role" {
  count     = try(var.teleport_integrations.cluster_discovery, false) ? 1 : 0
  yaml_body = <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: teleport
rules:
- apiGroups:
  - ""
  resources:
  - users
  - groups
  - serviceaccounts
  verbs:
  - impersonate
- apiGroups:
  - ""
  resources:
  - pods
  verbs:
  - get
- apiGroups:
  - "authorization.k8s.io"
  resources:
  - selfsubjectaccessreviews
  - selfsubjectrulesreviews
  verbs:
  - create
EOF
}

resource "kubectl_manifest" "teleport-cluster-role-binding" {
  count = try(var.teleport_integrations.cluster_discovery, false) ? 1 : 0
  depends_on = [
    kubectl_manifest.teleport-cluster-role
  ]
  yaml_body = <<EOF
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: teleport
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: teleport
subjects:
- kind: Group
  name: teleport
  apiGroup: rbac.authorization.k8s.io
EOF
}

# resource "kubernetes_cluster_role_binding_v1" "teleport" {
#   metadata {
#     name = "teleport:eks:admin"
#   }
#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "ClusterRole"
#     name      = "cluster-admin"
#   }
#   subject {
#     kind      = "Group"
#     name      = "teleport:eks:admin"
#     api_group = "rbac.authorization.k8s.io"
#   }
# }