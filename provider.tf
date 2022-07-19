provider "aws" {
  region = var.aws_region
  profile = "default"
}
provider "aws" {
  alias = "secondary"
  profile = "default"
  region = var.aws_secondary_region
}