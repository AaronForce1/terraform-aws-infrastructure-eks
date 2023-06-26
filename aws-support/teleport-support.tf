## ----------------------------------
## Teleport EKS Auto-Discovery
## ----------------------------------
terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }
  }
}

resource "kubectl_manifest" "teleport-cluster-role" {
  count     = try(coalesce(var.aws_installations.teleport.cluster_discovery_support, false), false) ? 1 : 0
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
  count = try(coalesce(var.aws_installations.teleport.cluster_discovery_support, false), false) ? 1 : 0
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

## ----------------------------------
## Teleport Kubernetes Access Controls
## ----------------------------------
resource "kubectl_manifest" "teleport-Kubernetes-access-controls" {
  count = var.aws_installations.teleport.kubernetes_access_controls  != null ? length(flatten(var.aws_installations.teleport.kubernetes_access_controls.*.value_file)) : 0
  yaml_body = var.aws_installations.teleport.kubernetes_access_controls[count.index].value_file
}