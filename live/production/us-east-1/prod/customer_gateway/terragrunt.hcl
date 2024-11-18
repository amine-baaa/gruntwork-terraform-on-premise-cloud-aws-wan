include {
  path = find_in_parent_folders()
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders())}/envcommon/customer_gateway.hcl"
  expose = true
}

terraform {
  source = "${get_repo_root()}/modules/customer_gateway"
}

inputs = {
  customer_gateway_ip      = "203.0.113.1"
}
