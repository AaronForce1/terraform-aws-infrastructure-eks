provider "aws" {
  region = var.aws_region
}
provider "aws" {
  alias = "secondary"

  region = var.aws_secondary_region
}