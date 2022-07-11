provider "aws" {
  region = var.aws_region
  profile                  = var.aws_profile
  shared_config_files      = ["~/.aws/confing"]
  shared_credentials_files = ["~/.aws/credentials"]
}
provider "aws" {
  alias = "secondary"

  region = var.aws_secondary_region
  profile                  = var.aws_profile
  shared_config_files      = ["~/.aws/confing"]
  shared_credentials_files = ["~/.aws/credentials"]
}