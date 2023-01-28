include "root" {
  path = find_inparent_folders()
}

include "env" {
  path   = "${get_terragrunt_dir()}/../../_env/app.hcl"
  expose = true
}

# Override the terraform.source attribute to v0.2.0
terraform {
  source = "${include.env.locals.source_base_url}?ref=v0.2.0"
}