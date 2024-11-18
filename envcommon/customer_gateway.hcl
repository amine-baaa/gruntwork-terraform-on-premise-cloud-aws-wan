
locals {
  region_vars        = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars   = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  map_vars          = read_terragrunt_config(find_in_parent_folders("region_map.hcl"))
  region_index_map = local.map_vars.locals.region_index_map

  env                = local.environment_vars.locals.environment
  
  region             = local.region_vars.locals.aws_region

  base_asn = 65000


  env_index       = local.env == "dev" ? 0 : 1
  asn_offset      = (local.region_index_map[local.region] * 10) + local.env_index
  customer_gateway_bgp_asn = local.base_asn + local.asn_offset
}

inputs = {
  customer_gateway_name = "cgw-${local.region}-${local.env}"
  customer_gateway_bgp_asn = local.customer_gateway_bgp_asn
}
