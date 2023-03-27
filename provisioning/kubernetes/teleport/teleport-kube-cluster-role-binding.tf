resource "kubernetes_cluster_role_binding_v1" "teleport" {
  metadata {
    name = "teleport:eks:admin"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "Group"
    name      = "teleport:eks:admin"
    api_group = "rbac.authorization.k8s.io"
  }
}