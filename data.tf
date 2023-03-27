# tflint-ignore: terraform_unused_declarations
data "aws_caller_identity" "current" {}

data "local_file" "infrastructure-terraform-eks-version" {
  filename = "${path.module}/VERSION"
}
