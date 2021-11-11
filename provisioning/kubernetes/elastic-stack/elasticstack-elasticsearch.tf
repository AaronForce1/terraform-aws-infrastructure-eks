resource "helm_release" "elasticstack-elasticsearch" {
  name       = "elasticsearch"
  repository = "https://helm.elastic.co"
  chart      = "elasticsearch"
  version    = "v7.15.0"
  namespace  = "monitoring"

  values = [
    <<-EOF
      imagePullPolicy: Always
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
