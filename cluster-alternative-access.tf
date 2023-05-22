resource "kubectl_manifest" "configmaps_admin_service_account" {
  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "ServiceAccount"
    metadata = {
      name = "configmaps-admin"
      finalizers = ["kubernetes"]
    }
    secrets = [
      {
        name = "configmaps-admin-service-account-token"
      }
    ]
  })
}

resource "kubectl_manifest" "configmaps_admin_cluster_role" {
  yaml_body = yamlencode({
    apiVersion = "rbac.authorization.k8s.io/v1"
    kind       = "ClusterRole"
    metadata = {
      name = "configmaps-admin"
      finalizers = ["kubernetes"]
    }
    rules = [
      {
        apiGroups = [""]
        resources = ["configmaps"]
        verbs     = ["*"]
      }
    ]
  })
}

resource "kubectl_manifest" "configmaps_admin_cluster_role_binding" {
  yaml_body = yamlencode({
    apiVersion = "rbac.authorization.k8s.io/v1"
    kind       = "ClusterRoleBinding"
    metadata = {
      name = "configmaps-admin"
      finalizers = ["kubernetes"]
    }
    subjects = [
      {
        kind      = "ServiceAccount"
        name      = "configmaps-admin"
        namespace = "default"
      }
    ]
    roleRef = {
      kind     = "ClusterRole"
      name     = "configmaps-admin"
      apiGroup = "rbac.authorization.k8s.io"
    }
  })
}


resource "kubectl_manifest" "configmaps_admin_secret" {
  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "Secret"
    metadata = {
      name = "configmaps-admin-service-account-token"
      finalizers = ["kubernetes"]
      annotations = {
        "kubernetes.io/service-account.name" = "configmaps-admin"
      }
    }
    type = "kubernetes.io/service-account-token"
  })
}


data "kubernetes_secret" "configmaps_admin_secret" {
  metadata {
    name = "configmaps-admin-service-account-token"
  }
}

resource "aws_ssm_parameter" "configmaps_admin_service_account_token" {
  name  = "/${var.app_namespace}/${var.tfenv}/cluster-access-bearer-token"
  type  = "String"
  value = "${data.kubernetes_secret.configmaps_admin_secret.data.token}"
  description = "Decrypted token for accessing cluster by service account"
}