
output "global_network_id" {
   value = aws_networkmanager_global_network.global_network.id
}

output "core_network_id" {
  value = aws_networkmanager_core_network.core_network.id
}

output "core_network_arn" {
  value = aws_networkmanager_core_network.core_network.arn
}
