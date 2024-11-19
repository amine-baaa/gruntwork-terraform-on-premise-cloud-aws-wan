locals {
  enabled = true
}

resource "aws_networkfirewall_firewall_policy" "policy" {
  count = local.enabled ? 1 : 0
  name  = "firewall-policy"

  firewall_policy {
    stateless_default_actions          = ["aws:pass"]
    stateless_fragment_default_actions = ["aws:pass"]
  }

 
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
