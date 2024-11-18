
locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env = local.environment_vars.locals.environment
  region = local.region_vars.locals.aws_region
}

inputs = {
  vpn_connection_name          = "vpn-${local.region}-${local.env}"
}
