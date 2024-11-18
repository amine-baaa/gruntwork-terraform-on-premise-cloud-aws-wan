locals {
  region_vars        = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars   = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env                = local.environment_vars.locals.environment
  region             = local.region_vars.locals.aws_region

  top_cidr = "10.0.0.0/8"

  map_vars          = read_terragrunt_config(find_in_parent_folders("region_map.hcl"))
  region_index_map = local.map_vars.locals.region_index_map

  region_cidr = cidrsubnet(local.top_cidr, 8, local.region_index_map[local.region])

  env_index  = local.env == "production" ? 0 : 1
  vpc_cidr   = cidrsubnet(local.region_cidr, 1, local.env_index)

  private_subnets = [
    cidrsubnet(local.vpc_cidr, 8, 1),
    cidrsubnet(local.vpc_cidr, 8, 2)
  ]

  cwan_subnets = [
    cidrsubnet(local.vpc_cidr, 8, 3),
    cidrsubnet(local.vpc_cidr, 8, 4)
  ]

  public_subnets = [
    cidrsubnet(local.vpc_cidr, 8, 101),
    cidrsubnet(local.vpc_cidr, 8, 102)
  ]
}

inputs = {
  vpc_name          = "vpc-${local.region}-${local.env}"
  vpc_cidr_block    = local.vpc_cidr
  private_subnets    = local.private_subnets
  cwan_subnets     = local.cwan_subnets
}
