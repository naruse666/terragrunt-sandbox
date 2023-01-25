include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "git@github.com:naruse666/terraform-module-reference-from-terragrunt.git//modules/ec2?ref=v0.0.1"
}
inputs = {
  instance_type  = "t2.micro"
}