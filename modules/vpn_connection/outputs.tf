output "vpn_connection_id" {
  description = "The ID of the VPN connection"
  value       = aws_vpn_connection.vpn_connection.id
}
