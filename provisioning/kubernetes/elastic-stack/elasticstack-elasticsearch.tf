resource "helm_release" "elasticstack-elasticsearch" {
  name       = "elasticsearch"
  repository = "https://helm.elastic.co"
  chart      = "elasticsearch"
  version    = format("v%s", local.elkversion)
  namespace  = "monitoring"
  lifecycle { ignore_changes = [ values, version] }

  values = [
    <<-EOF
      image: registry.git.hk.asiaticketing.com/technology/system/utils/elasticsearch
      imageTag: ${local.elkversion}
      imagePullPolicy: Always
      imagePullSecrets: 
      - name: ticketing-v2-elasticsearch-backup-regcred
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
