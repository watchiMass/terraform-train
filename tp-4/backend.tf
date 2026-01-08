terraform {
  backend "s3" {
    bucket                   = "terraform-state-wongo"
    key                      = "infrastructure/terraform.tfstate"
    region                   = "us-east-1"
    dynamodb_table           = "terraform-locks-wongo"
    encrypt                  = true
    shared_credentials_files = ["../.secrets/credentials"]
    profile                  = "default"
  }
}