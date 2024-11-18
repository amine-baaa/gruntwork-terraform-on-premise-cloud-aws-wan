include {
  path = find_in_parent_folders()
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders())}/envcommon/transit_gateway.hcl"
  expose = true
}

terraform {
  source = "${get_repo_root()}/modules/transit_gateway"
}

dependency "cloud_wan" {
  config_path = "${get_repo_root()}/live/global/cloud_wan"
}

inputs = {
  core_network_id            = dependency.cloud_wan.outputs.core_network_id
  global_network_id          = dependency.cloud_wan.outputs.global_network_id
}


