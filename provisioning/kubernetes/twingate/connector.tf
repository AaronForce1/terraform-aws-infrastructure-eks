resource "twingate_remote_network" "aws_network" {
  name     = var.name
  location = "AWS"
}

# resource "random_pet" "connector_name" {
#   count = var.connector_count
# }

resource "twingate_connector" "aws_connector" {
  count = var.connector_count

  remote_network_id = twingate_remote_network.aws_network.id
  # name = each.key
}

resource "twingate_connector_tokens" "aws_connector_tokens" {
  count = var.connector_count

  connector_id = twingate_connector.aws_connector[count.index].id
}
