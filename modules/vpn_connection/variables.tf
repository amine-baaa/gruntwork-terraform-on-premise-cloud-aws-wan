
variable "customer_gateway_id" {
  description = "The ID of the Customer Gateway to associate with the VPN"
  type        = string
}

variable "transit_gateway_id" {
  description = "The ID of the Transit Gateway to associate with the VPN"
  type        = string
}

variable "vpn_connection_name" {
  description = "Name of the VPN Connection"
  type        = string
}