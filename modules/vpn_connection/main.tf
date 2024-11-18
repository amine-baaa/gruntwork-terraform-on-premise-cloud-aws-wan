resource "aws_vpn_connection" "vpn_connection" {
  customer_gateway_id = var.customer_gateway_id
  transit_gateway_id  = var.transit_gateway_id
  type                = "ipsec.1"

  static_routes_only = false

  tags = {
    Name = var.vpn_connection_name
  }
}


