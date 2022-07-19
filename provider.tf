provider "aws" {
  region = var.aws_region
  profile = var.aws_profile
}
provider "aws" {
  alias = "secondary"
  profile = var.aws_profile
  region = var.aws_secondary_region
}