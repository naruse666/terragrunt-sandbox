include "root" {
  path = find_in_parent_folders()
}

dependencies {
  path = ["../frontend"]
}

terraform {
  extra_arguments "common_vars" {
    commands = ["plan", "apply"]

    arguments = [
      "-var-file=../region.tfvars"
    ]
  }
}