include {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_repo_root()}/modules/vpn_connection"
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders())}/envcommon/vpn_connection.hcl"
  expose = true
}

dependency "customer_gateway" {
  config_path = "../customer_gateway"
}

dependency "transit_gateway" {
  config_path = "../transit_gateway"
}

inputs = {
  customer_gateway_id   = dependency.customer_gateway.outputs.customer_gateway_id
  transit_gateway_id    = dependency.transit_gateway.outputs.transit_gateway_id
}
