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