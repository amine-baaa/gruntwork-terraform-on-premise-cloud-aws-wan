variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones for the VPC"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = []
}

variable "cwan_subnets" {
  description = "List of CWAN subnet CIDR blocks"
  type        = list(string)
  default     = []
}

variable "fw_subnets" {
  description = "List of Firewall (FW) subnet CIDR blocks"
  type        = list(string)
  default     = []
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "core_network_id" {
  description = "The ID of the core network to attach the VPC"
  type        = string
}

variable "core_network_arn" {
  description = "The ARN of the core network to attach the VPC"
  type        = string
}

variable "firewall_endpoint_id" {
  description = "The ID of the Firewall Endpoint for routing 0.0.0.0/0"
  type        = string
}

variable "region" {
  description = "The AWS region where the resources will be created"
  type        = string
}
