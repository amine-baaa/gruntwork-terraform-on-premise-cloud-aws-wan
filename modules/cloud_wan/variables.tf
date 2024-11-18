
variable "global_network_description" {
  description = "Description for the global network"
  type        = string
}

variable "core_network_description" {
  description = "Description for the core network"
  type        = string
}

variable "asn_ranges" {
  description = "ASN ranges for the core network configuration"
  type        = list(string)
  default     = ["65022-65534"]
}

variable "edge_locations" {
  description = "A list of edge locations with their ASNs"
  type = list(object({
    location = string
    asn      = string
  }))
}
