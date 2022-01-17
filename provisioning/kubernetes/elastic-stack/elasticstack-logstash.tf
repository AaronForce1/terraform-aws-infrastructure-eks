resource "helm_release" "elasticstack-logstash" {
  name       = "logstash"
  repository = "https://helm.elastic.co"
  chart      = "logstash"
  version    = format("v%s", local.elkversion)
  namespace  = "monitoring"
  lifecycle { ignore_changes = [ values, version] }

  values = [
    <<-EOF
      imagePullPolicy: Always
      logstashConfig:
        ${local.logstash_yml}
      logstashPipeline:
        ${local.logstash_conf}
      service:
        type: ClusterIP
        loadBalancerIP: ""
        ports:
          - name: "logstash"
            port: 5044
            protocol: "TCP"
          - name: "http"
            port: 8080
            targetPort: 8080
      resources:
        limits:
          cpu: "2"
          memory: "2560Mi"
    EOF
  ]

  depends_on = [module.s3_elasticstack_bucket, module.iam_user, aws_iam_user_policy_attachment.s3_attach]
}

locals {
  logstash_yml = indent(2, yamlencode({
    "logstash.yml" : <<-EOF
  http.host: 0.0.0.0
  monitoring.elasticsearch.hosts: "http://elasticsearch-master:9200"
  EOF
  }))
  logstash_conf = indent(4, yamlencode({
    "logstash.conf" : <<-EOF
  input {
    beats {
      port => 5044
    }
  }
  output { 
    elasticsearch {
      hosts => ["http://elasticsearch-master:9200"]
      index => "filebeat-%%{[agent.version]}-%%{+yyyy.MM.dd}" 
    }
    s3 {
      access_key_id => ${module.iam_user.this_iam_access_key_id}
      secret_access_key => "${module.iam_user.this_iam_access_key_secret}"
      endpoint => "https://s3.ap-southeast-1.amazonaws.com"
      region => "${var.aws_region}"
      bucket => "${var.app_name}-${var.app_namespace}-${var.tfenv}-elasticstack-logs"
      additional_settings => {
        "force_path_style" => true
      }
    }
  }
    EOF
  }))
}
