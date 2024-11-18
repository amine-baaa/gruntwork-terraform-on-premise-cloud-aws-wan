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