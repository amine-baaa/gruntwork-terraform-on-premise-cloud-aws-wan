include {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_repo_root()}/modules/firewall"
}

dependency "inspection_vpc" {
  config_path = "../inspection_vpc"
}

inputs = {
  vpc_id                            = dependency.inspection_vpc.outputs.vpc_id
  subnet_ids                        = dependency.inspection_vpc.outputs.fw_subnet_ids
  firewall_name                     = "firewall"
}
