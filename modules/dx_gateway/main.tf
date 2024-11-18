resource "aws_dx_gateway" "dx_gateway" {
  name           = var.dx_gateway_name
  amazon_side_asn = var.dx_gateway_amazon_asn
}

resource "aws_dx_gateway_association" "dx_gateway_association" {
  dx_gateway_id         = aws_dx_gateway.dx_gateway.id
  associated_gateway_id = var.associated_transit_gateway_id
  allowed_prefixes      = var.allowed_prefix_list
}

output "dx_gateway_id" {
  description = "The ID of the created Direct Connect Gateway"
  value       = aws_dx_gateway.dx_gateway.id
}

output "dx_gateway_association_id" {
  description = "The ID of the Direct Connect Gateway Association"
  value       = aws_dx_gateway_association.dx_gateway_association.id
}

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
