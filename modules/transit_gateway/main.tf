resource "aws_ec2_transit_gateway" "transit_gateway" {
  description                     = var.transit_gateway_name
  amazon_side_asn                 = var.transit_gateway_amazon_asn
}

resource "aws_networkmanager_transit_gateway_registration" "tgw_registration" {
  global_network_id  = var.global_network_id
  transit_gateway_arn = aws_ec2_transit_gateway.transit_gateway.arn
}

resource "aws_networkmanager_transit_gateway_peering" "cloudwan_tgw_peering" {
  core_network_id     = var.core_network_id  
  transit_gateway_arn = aws_ec2_transit_gateway.transit_gateway.arn
  tags = {
    Segment = "hybrid"
  }
}

resource "aws_ec2_transit_gateway_policy_table" "policy_table" {
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id
}

resource "aws_ec2_transit_gateway_policy_table_association" "policy_table_association" {
  transit_gateway_attachment_id   = aws_networkmanager_transit_gateway_peering.cloudwan_tgw_peering.transit_gateway_peering_attachment_id
  transit_gateway_policy_table_id = aws_ec2_transit_gateway_policy_table.policy_table.id
 
}

output "transit_gateway_id" {
  description = "The ID of the created Transit Gateway"
  value       = aws_ec2_transit_gateway.transit_gateway.id
}

output "peering_connection_id" {
  description = "The ID of the Cloud WAN and Transit Gateway peering connection"
  value       = aws_networkmanager_transit_gateway_peering.cloudwan_tgw_peering.id
}

output "peering_connection_type" {
  description = "The type of peering connection between Cloud WAN and Transit Gateway"
  value       = aws_networkmanager_transit_gateway_peering.cloudwan_tgw_peering.peering_type
}

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
