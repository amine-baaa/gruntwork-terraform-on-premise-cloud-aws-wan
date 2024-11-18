include {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_repo_root()}/modules/firewall"
}

dependency "egress_vpc" {
  config_path = "../egress_vpc"
}

inputs = {
  vpc_id                            = dependency.egress_vpc.outputs.vpc_id
  subnet_ids                        = dependency.egress_vpc.outputs.fw_subnet_ids
  firewall_name                     = "firewall"
}
