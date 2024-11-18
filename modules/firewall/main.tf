

locals {
  enabled = length(var.subnet_ids) > 0
}

resource "aws_networkfirewall_rule_group" "stateless" {
  count    = local.enabled ? 1 : 0
  capacity = 100
  name     = "stateless-rule-group"
  type     = "STATELESS"

  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {
        stateless_rule {
          priority = 1
          rule_definition {
            actions = ["aws:forward_to_sfe"]
            match_attributes {
              source {
                address_definition = "0.0.0.0/0"
              }
              destination {
                address_definition = "0.0.0.0/0"
              }
            }
          }
        }
      }
    }
  }

  tags = var.tags
}

resource "aws_networkfirewall_rule_group" "stateful" {
  count    = local.enabled ? 1 : 0
  capacity = 100
  name     = "stateful-rule-group"
  type     = "STATEFUL"

  rule_group {
    rules_source {}
  }

  tags = var.tags
}

resource "aws_networkfirewall_firewall_policy" "policy" {
  count = local.enabled ? 1 : 0
  name  = "firewall-policy"

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]
    stateful_default_actions           = ["aws:pass"]

    stateless_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.stateless[0].arn
      priority     = 100
    }

    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.stateful[0].arn
    }
  }

  tags = var.tags
}

resource "aws_networkfirewall_firewall" "firewall" {
  count               = local.enabled ? 1 : 0
  name                = var.firewall_name
  firewall_policy_arn = aws_networkfirewall_firewall_policy.policy[0].arn
  vpc_id              = var.vpc_id

  dynamic "subnet_mapping" {
    for_each = var.subnet_ids
    content {
      subnet_id = subnet_mapping.value
    }
  }

  delete_protection                 = var.delete_protection
  firewall_policy_change_protection = var.firewall_policy_change_protection
  subnet_change_protection          = var.subnet_change_protection

  tags = var.tags
}

output "firewall_id" {
  description = "ID of the Network Firewall"
  value       = length(aws_networkfirewall_firewall.firewall) > 0 ? aws_networkfirewall_firewall.firewall[0].id : null
}

output "firewall_policy_arn" {
  description = "ARN of the firewall policy"
  value       = length(aws_networkfirewall_firewall_policy.policy) > 0 ? aws_networkfirewall_firewall_policy.policy[0].arn : null
}

output "stateless_rule_group_arn" {
  description = "ARN of the stateless rule group"
  value       = length(aws_networkfirewall_rule_group.stateless) > 0 ? aws_networkfirewall_rule_group.stateless[0].arn : null
}

output "stateful_rule_group_arn" {
  description = "ARN of the stateful rule group"
  value       = length(aws_networkfirewall_rule_group.stateful) > 0 ? aws_networkfirewall_rule_group.stateful[0].arn : null
}



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
  default     = "example-firewall"
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
