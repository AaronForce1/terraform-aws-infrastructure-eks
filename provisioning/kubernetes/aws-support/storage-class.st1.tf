resource "kubernetes_storage_class" "st1-storage-class" {
  metadata {
    name = "st1"
  }
  storage_provisioner = "kubernetes.io/aws-ebs"
  parameters = {
    type = "st1"
  }
}