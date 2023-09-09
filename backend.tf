terraform {
  backend "s3" {
    bucket         = "terraform-state-assorted"
    key            = "ess/terraform.tfstate"
    dynamodb_table = "terraform-state-lock"
    region         = "eu-west-2"
  }
}
