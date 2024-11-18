include {
  path = find_in_parent_folders()
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders())}/envcommon/dx_gateway.hcl"
  expose = true
}

terraform {
  source = "${get_repo_root()}/modules/dx_gateway"
}

dependency "transit_gateway" {
    config_path = "../transit_gateway"
}
inputs = {
  associated_transit_gateway_id = dependency.transit_gateway.outputs.transit_gateway_id
  allowed_prefix_list          = ["10.0.0.0/16", "172.16.0.0/16"]
}
