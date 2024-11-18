resource "aws_dx_gateway" "dx_gateway" {
  name           = var.dx_gateway_name
  amazon_side_asn = var.dx_gateway_amazon_asn
}

resource "aws_dx_gateway_association" "dx_gateway_association" {
  dx_gateway_id         = aws_dx_gateway.dx_gateway.id
  associated_gateway_id = var.associated_transit_gateway_id
  allowed_prefixes      = var.allowed_prefix_list
}



