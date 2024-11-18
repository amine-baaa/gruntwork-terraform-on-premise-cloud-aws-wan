
variable "transit_gateway_name" {
  description = "Name of the Transit Gateway"
  type        = string
}

variable "transit_gateway_amazon_asn" {
  description = "Amazon-side ASN for the Transit Gateway"
  type        = number
}

variable "global_network_id" {
  description = "The ID of the Cloud WAN Global Network to register the Transit Gateway with"
  type        = string
}

variable "core_network_id" {
  description = "The ID of the Core Network to establish peering with the Transit Gateway"
  type        = string
}
