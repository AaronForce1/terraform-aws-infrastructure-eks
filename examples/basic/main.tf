module "infrastructure-terraform-eks" {
  source = "../.."

  aws_region       = "ap-southeast-1"
  tfenv            = "test-basic"
  root_domain_name = "basic.example.com"
}