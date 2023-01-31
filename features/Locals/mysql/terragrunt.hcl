locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
  region      = "us-east-1"
}