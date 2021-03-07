module "infrastructure-terraform-eks" {
  source = "../.."

  aws_region       = "ap-southeast-1"
  tfenv            = "example-testing-basic"
  root_domain_name = "basic.example.com"
}

module "datadog-dashboard" {
  source     = "./datadog-dashboard"
  depends_on = [module.infrastructure-terraform-eks]

  app_namespace  = "technology-system"
  tfenv          = "example-testing-basic"
  datadog_apikey = var.datadog_serviceacount_apikey
}