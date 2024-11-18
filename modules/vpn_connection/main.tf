resource "aws_vpn_connection" "vpn_connection" {
  customer_gateway_id = var.customer_gateway_id
  transit_gateway_id  = var.transit_gateway_id
  type                = "ipsec.1"

  static_routes_only = false

  tags = {
    Name = var.vpn_connection_name
  }
}

output "vpn_connection_id" {
  description = "The ID of the VPN connection"
  value       = aws_vpn_connection.vpn_connection.id
}

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
