variable "dx_gateway_name" {
  description = "Name of the Direct Connect Gateway"
  type        = string
}

variable "dx_gateway_amazon_asn" {
  description = "Amazon-side ASN for the Direct Connect Gateway"
  type        = number
}

variable "associated_transit_gateway_id" {
  description = "ID of the associated Transit Gateway"
  type        = string
}

variable "allowed_prefix_list" {
  description = "Prefixes to be allowed for the Direct Connect Gateway Association"
  type        = list(string)
}
