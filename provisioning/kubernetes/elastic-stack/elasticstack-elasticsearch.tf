resource "helm_release" "elasticstack-elasticsearch" {
  name       = "elasticsearch"
  repository = "https://helm.elastic.co"
  chart      = "elasticsearch"
  version    = local.elkversion
  namespace  = "monitoring"
  lifecycle { ignore_changes = [values, version] }

  values = [
    <<-EOF
      imageTag: ${local.elkversion}
      imagePullPolicy: IfNotPresent
      replicas: ${var.tfenv == "prod" ? 3 : 2}
      volumeClaimTemplate:
        resources:
          requests:
            storage: ${var.tfenv == "prod" ? "50Gi" : "20Gi"}
        storageClassName: gp3
      antiAffinity: ${var.tfenv == "prod" ? "hard" : "soft"}
      extraEnvs:
        - name: xpack.security.enabled
          value: "false"
    EOF
  ]
}
