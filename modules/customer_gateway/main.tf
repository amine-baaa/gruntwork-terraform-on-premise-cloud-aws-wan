resource "aws_customer_gateway" "customer_gateway" {
  bgp_asn    = var.customer_gateway_bgp_asn
  ip_address = var.customer_gateway_ip
  type       = "ipsec.1"

  tags = {
    Name = var.customer_gateway_name
  }
}

variable "customer_gateway_bgp_asn" {
  description = "BGP ASN for the Customer Gateway"
  type        = number
}

variable "customer_gateway_ip" {
  description = "IP address of the Customer Gateway"
  type        = string
}

variable "customer_gateway_name" {
  description = "Name of the Customer Gateway"
  type        = string
}

output "customer_gateway_id" {
  description = "The ID of the Customer Gateway"
  value       = aws_customer_gateway.customer_gateway.id
}

