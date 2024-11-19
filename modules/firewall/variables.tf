
variable "vpc_id" {
  description = "VPC ID where the firewall will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the firewall"
  type        = list(string)
}

variable "firewall_name" {
  description = "Name of the Network Firewall"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the resources"
  type        = map(string)
  default     = {
    Environment = "dev"
    Project     = "network-firewall"
  }
}

variable "delete_protection" {
  description = "Enable delete protection"
  type        = bool
  default     = false
}

variable "firewall_policy_change_protection" {
  description = "Enable firewall policy change protection"
  type        = bool
  default     = false
}

variable "subnet_change_protection" {
  description = "Enable subnet change protection"
  type        = bool
  default     = false
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}
