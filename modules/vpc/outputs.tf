
output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnet[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnet[*].id
}

output "cwan_subnet_ids" {
  value = aws_subnet.cwan_subnet[*].id
}

output "fw_subnet_ids" {
  value = aws_subnet.fw_subnet[*].id
}

output "nat_gateway_ids" {
  value = aws_nat_gateway.nat[*].id
}

output "vpc_attachment_id" {
  value = aws_networkmanager_vpc_attachment.nm_vpc_attachment.id
}
