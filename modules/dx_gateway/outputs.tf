output "dx_gateway_id" {
  description = "The ID of the created Direct Connect Gateway"
  value       = aws_dx_gateway.dx_gateway.id
}

output "dx_gateway_association_id" {
  description = "The ID of the Direct Connect Gateway Association"
  value       = aws_dx_gateway_association.dx_gateway_association.id
}