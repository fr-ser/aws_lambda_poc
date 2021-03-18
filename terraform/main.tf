terraform {
  required_version = ">= 0.14"

  # in a production environment the terraform state should most likely
  # be in a remote backend like s3

  #   backend "s3" {
  #     bucket  = "poc-terraform-state"
  #     key     = "poc/staging/terraform.tfstate"
  #     region  = "eu-central-1"
  #     encrypt = true
  #   }

}

provider "aws" {
  region  = "eu-central-1"
  profile = "private"
}
