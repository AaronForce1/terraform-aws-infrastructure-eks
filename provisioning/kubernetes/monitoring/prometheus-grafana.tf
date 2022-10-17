resource "helm_release" "prometheus" {
  name       = "${var.app_namespace}-${var.tfenv}"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"
  version    = coalesce(var.custom_version, "39.12.1")

  values = var.custom_manifest != null ? [var.custom_manifest] : [<<EOT
# Values for kube-prometheus-stack.
namespaceOverride: monitoring

## Create default rules for monitoring the cluster
##
defaultRules:
  create: true
  rules:
    alertmanager: true
    etcd: true
    configReloaders: true
    general: true
    k8s: true
    kubeApiserverAvailability: true
    kubeApiserverBurnrate: true
    kubeApiserverHistogram: true
    kubeApiserverSlos: true
    kubeControllerManager: true
    kubelet: true
    kubeProxy: true
    kubePrometheusGeneral: true
    kubePrometheusNodeRecording: true
    kubernetesApps: true
    kubernetesResources: true
    kubernetesStorage: true
    kubernetesSystem: true
    kubeScheduler: true
    kubeStateMetrics: true
    network: true
    node: true
    nodeExporterAlerting: true
    nodeExporterRecording: true
    prometheus: true
    prometheusOperator: true

  ## Reduce app namespace alert scope
  appNamespacesTarget: ".*"

  ## Prefix for runbook URLs. Use this to override the first part of the runbookURLs that is common to all rules.
  runbookUrl: "https://runbooks.prometheus-operator.dev/runbooks"

## Configuration for alertmanager
## ref: https://prometheus.io/docs/alerting/alertmanager/
##
alertmanager:
  enabled: true

## Using default values from https://github.com/grafana/helm-charts/blob/main/charts/grafana/values.yaml
##
grafana:
  enabled: true

  ## Deploy default dashboards
  ##
  defaultDashboardsEnabled: true

  ## Timezone for the default dashboards
  ## Other options are: browser or a specific timezone, i.e. Europe/Luxembourg
  ##
  defaultDashboardsTimezone: Asia/Hong_Kong

  dashboardProviders:
    dashboardproviders.yaml:
      apiVersion: 1
      providers:
        - name: default
          orgId: 1
          folder: ""
          type: "file"
          disableDeletion: "false"
          editable: "true"
          options:
            path: "/var/lib/grafana/dashboards/default"
            foldersFromFilesStructure: "true"
  dashboards:
    default:
      storage-volume-dashboard:
        gnetId: 11454
        datasource: Prometheus
      k8-cluster-detailed-dashboard:
        gnetId: 10856
        datasource: Prometheus
      coredns-dashboard:
        gnetId: 7279
        datasource: Prometheus
      k8s-cluster-summary-dashboard:
        gnetId: 8685
        datasource: Prometheus
      k8s-app-metrics-dashboard:
        gnetId: 1471
        datasource: Prometheus
      k8s-capacity-dashboard:
        gnetId: 5228
        datasource: Prometheus
      k8s-cluster-dashboard:
        gnetId: 6417
        datasource: Prometheus
      k8s-cpu-mem-network-dashboard:
        gnetId: 5225
        datasource: Prometheus
      k8s-detailed-node-dashboard:
        gnetId: 12740
        datasource: Prometheus
      k8s-cpu-mem-net-pod-dashboard:
        gnetId: 6588
        datasource: Prometheus
      pod-stat-info-dashboard:
        gnetId: 10518
        datasource: Prometheus
  imageRenderer:
    enabled: "true"

  grafana.ini:
    auth.google:
      enabled: "true"
      allow_sign_up: "true"
      client_id: ${var.google_clientID}
      client_secret: ${var.google_clientSecret}
      scopes: "https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email"
      token_url: "https://accounts.google.com/o/oauth2/token"
      auth_url: "https://accounts.google.com/o/oauth2/auth"
      api_url: "https://www.googleapis.com/oauth2/v1/userinfo"
      allowed_domains: "${var.google_authDomain}"

  persistence:
    enabled: "true"
    size: "${var.tfenv == "prod" ? "60Gi" : "20Gi"}"
    storageClassName: "gp3"

  ingress:
    enabled: "true"
    ingressClassName: nginx
    annotations:
      kubernetes.io/tls-acme: "true"
      cert-manager.io/cluster-issuer: letsencrypt-prod
    labels:
      env: ${var.tfenv}
      app: grafana
      tier: support
    hosts:
      - "grafana.${var.app_namespace}-${var.tfenv}.${var.root_domain_name}"
    tls:
      - secretName: "grafana-${var.app_namespace}-${var.tfenv}-ing-tls"
        hosts:
          - "grafana.${var.app_namespace}-${var.tfenv}.${var.root_domain_name}"

  ## Passed to grafana subchart and used by servicemonitor below
  ##
  service:
    portName: http-web

  serviceMonitor:
    # If true, a ServiceMonitor CRD is created for a prometheus operator
    # https://github.com/coreos/prometheus-operator
    #
    enabled: true

    # Path to use for scraping metrics. Might be different if server.root_url is set
    # in grafana.ini
    path: "/metrics"

    #  namespace: monitoring  (defaults to use the namespace this chart is deployed to)

    # labels for the ServiceMonitor
    labels: {}

    # Scrape interval. If not set, the Prometheus default scrape interval is used.
    #
    interval: ""
    scheme: http
    tlsConfig: {}
    scrapeTimeout: 30s

    ## RelabelConfigs to apply to samples before scraping
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    relabelings: []
    # - sourceLabels: [__meta_kubernetes_pod_node_name]
    #   separator: ;
    #   regex: ^(.*)$
    #   targetLabel: nodename
    #   replacement: $1
    #   action: replace

## Component scraping the kube api server
##
kubeApiServer:
  enabled: true
  tlsConfig:
    serverName: kubernetes
    insecureSkipVerify: false
  serviceMonitor:
    ## Scrape interval. If not set, the Prometheus default scrape interval is used.
    ##
    interval: ""
    ## proxyUrl: URL of a proxy that should be used for scraping.
    ##
    proxyUrl: ""

    jobLabel: component
    selector:
      matchLabels:
        component: apiserver
        provider: kubernetes

    ## MetricRelabelConfigs to apply to samples after scraping, but before ingestion.
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    metricRelabelings:
      # Drop excessively noisy apiserver buckets.
      - action: drop
        regex: apiserver_request_duration_seconds_bucket;(0.15|0.2|0.3|0.35|0.4|0.45|0.6|0.7|0.8|0.9|1.25|1.5|1.75|2|3|3.5|4|4.5|6|7|8|9|15|25|40|50)
        sourceLabels:
          - __name__
          - le
    # - action: keep
    #   regex: 'kube_(daemonset|deployment|pod|namespace|node|statefulset).+'
    #   sourceLabels: [__name__]

    ## RelabelConfigs to apply to samples before scraping
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    relabelings: []
    # - sourceLabels:
    #     - __meta_kubernetes_namespace
    #     - __meta_kubernetes_service_name
    #     - __meta_kubernetes_endpoint_port_name
    #   action: keep
    #   regex: default;kubernetes;https
    # - targetLabel: __address__
    #   replacement: kubernetes.default.svc:443

    ## Additional labels
    ##
    additionalLabels: {}
    #  foo: bar

## Component scraping the kubelet and kubelet-hosted cAdvisor
##
kubelet:
  enabled: true
  namespace: kube-system

  serviceMonitor:
    ## Scrape interval. If not set, the Prometheus default scrape interval is used.
    ##
    interval: ""

    ## proxyUrl: URL of a proxy that should be used for scraping.
    ##
    proxyUrl: ""

    ## Enable scraping the kubelet over https. For requirements to enable this see
    ## https://github.com/prometheus-operator/prometheus-operator/issues/926
    ##
    https: true

    ## Enable scraping /metrics/cadvisor from kubelet's service
    ##
    cAdvisor: true

    ## Enable scraping /metrics/probes from kubelet's service
    ##
    probes: true

    ## Enable scraping /metrics/resource from kubelet's service
    ## This is disabled by default because container metrics are already exposed by cAdvisor
    ##
    resource: false
    # From kubernetes 1.18, /metrics/resource/v1alpha1 renamed to /metrics/resource
    resourcePath: "/metrics/resource/v1alpha1"

    ## MetricRelabelConfigs to apply to samples after scraping, but before ingestion.
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    cAdvisorMetricRelabelings:
      # Drop less useful container CPU metrics.
      - sourceLabels: [__name__]
        action: drop
        regex: 'container_cpu_(cfs_throttled_seconds_total|load_average_10s|system_seconds_total|user_seconds_total)'
      # Drop less useful container / always zero filesystem metrics.
      - sourceLabels: [__name__]
        action: drop
        regex: 'container_fs_(io_current|io_time_seconds_total|io_time_weighted_seconds_total|reads_merged_total|sector_reads_total|sector_writes_total|writes_merged_total)'
      # Drop less useful / always zero container memory metrics.
      - sourceLabels: [__name__]
        action: drop
        regex: 'container_memory_(mapped_file|swap)'
      # Drop less useful container process metrics.
      - sourceLabels: [__name__]
        action: drop
        regex: 'container_(file_descriptors|tasks_state|threads_max)'
      # Drop container spec metrics that overlap with kube-state-metrics.
      - sourceLabels: [__name__]
        action: drop
        regex: 'container_spec.*'
      # Drop cgroup metrics with no pod.
      - sourceLabels: [id, pod]
        action: drop
        regex: '.+;'
    # - sourceLabels: [__name__, image]
    #   separator: ;
    #   regex: container_([a-z_]+);
    #   replacement: $1
    #   action: drop
    # - sourceLabels: [__name__]
    #   separator: ;
    #   regex: container_(network_tcp_usage_total|network_udp_usage_total|tasks_state|cpu_load_average_10s)
    #   replacement: $1
    #   action: drop

    ## MetricRelabelConfigs to apply to samples after scraping, but before ingestion.
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    probesMetricRelabelings: []
    # - sourceLabels: [__name__, image]
    #   separator: ;
    #   regex: container_([a-z_]+);
    #   replacement: $1
    #   action: drop
    # - sourceLabels: [__name__]
    #   separator: ;
    #   regex: container_(network_tcp_usage_total|network_udp_usage_total|tasks_state|cpu_load_average_10s)
    #   replacement: $1
    #   action: drop

    ## RelabelConfigs to apply to samples before scraping
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    ## metrics_path is required to match upstream rules and charts
    cAdvisorRelabelings:
      - sourceLabels: [__metrics_path__]
        targetLabel: metrics_path
    # - sourceLabels: [__meta_kubernetes_pod_node_name]
    #   separator: ;
    #   regex: ^(.*)$
    #   targetLabel: nodename
    #   replacement: $1
    #   action: replace

    ## RelabelConfigs to apply to samples before scraping
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    probesRelabelings:
      - sourceLabels: [__metrics_path__]
        targetLabel: metrics_path
    # - sourceLabels: [__meta_kubernetes_pod_node_name]
    #   separator: ;
    #   regex: ^(.*)$
    #   targetLabel: nodename
    #   replacement: $1
    #   action: replace

    ## RelabelConfigs to apply to samples before scraping
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    resourceRelabelings:
      - sourceLabels: [__metrics_path__]
        targetLabel: metrics_path
    # - sourceLabels: [__meta_kubernetes_pod_node_name]
    #   separator: ;
    #   regex: ^(.*)$
    #   targetLabel: nodename
    #   replacement: $1
    #   action: replace

    ## MetricRelabelConfigs to apply to samples after scraping, but before ingestion.
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    metricRelabelings: []
    # - sourceLabels: [__name__, image]
    #   separator: ;
    #   regex: container_([a-z_]+);
    #   replacement: $1
    #   action: drop
    # - sourceLabels: [__name__]
    #   separator: ;
    #   regex: container_(network_tcp_usage_total|network_udp_usage_total|tasks_state|cpu_load_average_10s)
    #   replacement: $1
    #   action: drop

    ## RelabelConfigs to apply to samples before scraping
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    ## metrics_path is required to match upstream rules and charts
    relabelings:
      - sourceLabels: [__metrics_path__]
        targetLabel: metrics_path
    # - sourceLabels: [__meta_kubernetes_pod_node_name]
    #   separator: ;
    #   regex: ^(.*)$
    #   targetLabel: nodename
    #   replacement: $1
    #   action: replace

    ## Additional labels
    ##
    additionalLabels: {}
    #  foo: bar

## Component scraping the kube controller manager
##
kubeControllerManager:
  enabled: true

  ## If your kube controller manager is not deployed as a pod, specify IPs it can be found on
  ##
  endpoints: []
  # - 10.141.4.22
  # - 10.141.4.23
  # - 10.141.4.24

  ## If using kubeControllerManager.endpoints only the port and targetPort are used
  ##
  service:
    enabled: true
    ## If null or unset, the value is determined dynamically based on target Kubernetes version due to change
    ## of default port in Kubernetes 1.22.
    ##
    port: null
    targetPort: null
    # selector:
    #   component: kube-controller-manager

  serviceMonitor:
    enabled: true
    ## Scrape interval. If not set, the Prometheus default scrape interval is used.
    ##
    interval: ""

    ## proxyUrl: URL of a proxy that should be used for scraping.
    ##
    proxyUrl: ""

    ## Enable scraping kube-controller-manager over https.
    ## Requires proper certs (not self-signed) and delegated authentication/authorization checks.
    ## If null or unset, the value is determined dynamically based on target Kubernetes version.
    ##
    https: null

    # Skip TLS certificate validation when scraping
    insecureSkipVerify: null

    # Name of the server to use when validating TLS certificate
    serverName: null

    ## MetricRelabelConfigs to apply to samples after scraping, but before ingestion.
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    metricRelabelings: []
    # - action: keep
    #   regex: 'kube_(daemonset|deployment|pod|namespace|node|statefulset).+'
    #   sourceLabels: [__name__]

    ## RelabelConfigs to apply to samples before scraping
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    relabelings: []
    # - sourceLabels: [__meta_kubernetes_pod_node_name]
    #   separator: ;
    #   regex: ^(.*)$
    #   targetLabel: nodename
    #   replacement: $1
    #   action: replace

    ## Additional labels
    ##
    additionalLabels: {}
    #  foo: bar

## Component scraping coreDns. Use either this or kubeDns
##
coreDns:
  enabled: true
  service:
    port: 9153
    targetPort: 9153
    # selector:
    #   k8s-app: kube-dns
  serviceMonitor:
    ## Scrape interval. If not set, the Prometheus default scrape interval is used.
    ##
    interval: ""

    ## proxyUrl: URL of a proxy that should be used for scraping.
    ##
    proxyUrl: ""

    ## MetricRelabelConfigs to apply to samples after scraping, but before ingestion.
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    metricRelabelings: []
    # - action: keep
    #   regex: 'kube_(daemonset|deployment|pod|namespace|node|statefulset).+'
    #   sourceLabels: [__name__]

    ## RelabelConfigs to apply to samples before scraping
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    relabelings: []
    # - sourceLabels: [__meta_kubernetes_pod_node_name]
    #   separator: ;
    #   regex: ^(.*)$
    #   targetLabel: nodename
    #   replacement: $1
    #   action: replace

    ## Additional labels
    ##
    additionalLabels: {}
    #  foo: bar

## Component scraping kubeDns. Use either this or coreDns
##
kubeDns:
  enabled: false
  service:
    dnsmasq:
      port: 10054
      targetPort: 10054
    skydns:
      port: 10055
      targetPort: 10055
    # selector:
    #   k8s-app: kube-dns
  serviceMonitor:
    ## Scrape interval. If not set, the Prometheus default scrape interval is used.
    ##
    interval: ""

    ## proxyUrl: URL of a proxy that should be used for scraping.
    ##
    proxyUrl: ""

    ## MetricRelabelConfigs to apply to samples after scraping, but before ingestion.
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    metricRelabelings: []
    # - action: keep
    #   regex: 'kube_(daemonset|deployment|pod|namespace|node|statefulset).+'
    #   sourceLabels: [__name__]

    ## RelabelConfigs to apply to samples before scraping
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    relabelings: []
    # - sourceLabels: [__meta_kubernetes_pod_node_name]
    #   separator: ;
    #   regex: ^(.*)$
    #   targetLabel: nodename
    #   replacement: $1
    #   action: replace

    ## MetricRelabelConfigs to apply to samples after scraping, but before ingestion.
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    dnsmasqMetricRelabelings: []
    # - action: keep
    #   regex: 'kube_(daemonset|deployment|pod|namespace|node|statefulset).+'
    #   sourceLabels: [__name__]

    ## RelabelConfigs to apply to samples before scraping
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    dnsmasqRelabelings: []
    # - sourceLabels: [__meta_kubernetes_pod_node_name]
    #   separator: ;
    #   regex: ^(.*)$
    #   targetLabel: nodename
    #   replacement: $1
    #   action: replace

    ## Additional labels
    ##
    additionalLabels: {}
    #  foo: bar

## Component scraping etcd
##
kubeEtcd:
  enabled: false

## Component scraping kube scheduler
##
kubeScheduler:
  enabled: false

## Component scraping kube proxy
##
kubeProxy:
  enabled: true

## Component scraping kube state metrics
##
kubeStateMetrics:
  enabled: true

## Configuration for kube-state-metrics subchart
##
kube-state-metrics:
  selfMonitor:
    enabled: true
EOT
  ]
}
