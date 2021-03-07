data "local_file" "infrastructure-terraform-eks-version" {
  filename = "${path.module}/VERSION"
}