include {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_repo_root()}/modules/vpc"
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders())}/envcommon/inspection_vpc.hcl"
  expose = true
}

dependency "cloud_wan" {
  config_path = "${get_repo_root()}/live/global/cloud_wan"
}

inputs = {
  availability_zones = ["us-east-1a", "us-east-1b"]
  core_network_id    = dependency.cloud_wan.outputs.core_network_id
}
