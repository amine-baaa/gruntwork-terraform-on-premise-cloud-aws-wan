variable "customer_gateway_bgp_asn" {
  description = "BGP ASN for the Customer Gateway"
  type        = number
}

variable "customer_gateway_ip" {
  description = "IP address of the Customer Gateway"
  type        = string
}

variable "customer_gateway_name" {
  description = "Name of the Customer Gateway"
  type        = string
}