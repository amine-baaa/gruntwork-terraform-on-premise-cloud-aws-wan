locals {
  region_vars        = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars   = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env                = local.environment_vars.locals.environment
  region             = local.region_vars.locals.aws_region

 //CGNAT range
  top_cidr = "100.64.0.0/10"

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


  fw_subnets = [
    cidrsubnet(local.vpc_cidr, 8, 5),
    cidrsubnet(local.vpc_cidr, 8, 6)
  ]

  public_subnets = [
    cidrsubnet(local.vpc_cidr, 8, 101),
    cidrsubnet(local.vpc_cidr, 8, 102)
  ]
}

inputs = {
  vpc_name          = "egress-vpc-${local.region}-${local.env}"
  vpc_cidr_block    = local.vpc_cidr
  public_subnets    = local.public_subnets
  fw_subnets        = local.fw_subnets
  cwan_subnets      = local.cwan_subnets
}
