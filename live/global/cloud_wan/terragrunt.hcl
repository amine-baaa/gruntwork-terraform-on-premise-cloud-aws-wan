include {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_repo_root()}/modules/cloud_wan"
}

inputs = {
  global_network_description       = "My Global Network"
  core_network_description         = "My Core Network"

  asn_ranges                       = ["65022-65534"]

  edge_locations = [
    { location = "us-east-1", asn = "65500" },
    { location = "eu-central-1", asn = "65502" }
  ]
}
