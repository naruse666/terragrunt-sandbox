locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env_name = local.env_vars.locals.env

  source_base_url = "github.com/<org>/modules.git//app"
}

terraform {
  source = "${ local.source_base_url }?ref=v0.1.0"
}

dependency "vpc" {
  config_path = "../vpc"
}

dependency "mysql" {
  config_path = "../mysql"
}

inputs = {
  env = local.env_name
  basename       = "example-app-${local.env_name}"
  vpc_id         = dependency.vpc.outputs.vpc_id
  subnet_ids     = dependency.vpc.outputs.subnet_ids
  mysql_endpoint = dependency.mysql.outputs.endpoint
}