module "twingate" {
  source     = "./provisioning/kubernetes/twingate"

  count = var.helm_installations.twingate ? 1 : 0

  chart_version   = try(var.helm_configurations.twingate.chart_version, "")
  custom_manifest = try(var.helm_configurations.twingate.values_file, "")
  image_url       = coalesce(var.helm_configurations.twingate.registryURL, "twingate/connector")

  name                            = "${var.app_name}-${var.app_namespace}-${var.tfenv}"
  url                             = coalesce(var.helm_configurations.twingate.url, "twingate.com")
  network_name                    = coalesce(var.helm_configurations.twingate.network, "")
  management_group_configurations = try(var.helm_configurations.twingate.management_group_configurations, [])
  connector_count                 = coalesce(var.helm_configurations.twingate.connectorCount, 2)
  cluster_endpoint                = replace(data.aws_eks_cluster.cluster.endpoint, "https://", "")
  additional_resources            = coalesce(var.helm_configurations.twingate.resources, [])
  legacy_resource_list            = var.helm_configurations.twingate.resource_manifest

  logLevel = coalesce(var.helm_configurations.twingate.logLevel, "error")
}

