provider "aws" {
  region = var.aws_region
  profile                  = var.aws_profile
}
provider "aws" {
  alias = "secondary"

  region = var.aws_secondary_region
  profile                  = var.aws_profile
}