# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
terraform {
  backend "s3" {
    bucket         = "tf-backend"
    dynamodb_table = "tf-backend"
    encrypt        = true
    key            = "terragrunt-stg/frontend/terraform.tfstate"
    region         = "ap-northeast-1"
  }
}
