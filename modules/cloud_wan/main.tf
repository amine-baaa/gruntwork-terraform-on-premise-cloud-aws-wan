resource "aws_networkmanager_global_network" "global_network" {
  description = var.global_network_description
}
data "aws_networkmanager_core_network_policy_document" "core_network_policy" {
  core_network_configuration {
    asn_ranges = var.asn_ranges
    dynamic "edge_locations" {
      for_each = var.edge_locations
      content {
        location = edge_locations.value["location"]
        asn      = edge_locations.value["asn"]
      }
    }
  }

  network_function_groups {
    name                        = "inspection"
    require_attachment_acceptance = false
  }

  segments {
    name                          = "production"
    description                   = "Production Segment"
    isolate_attachments           = false
    require_attachment_acceptance = false
  }

  segments {
    name                          = "hybrid"
    description                   = "Hybrid Segment"
    isolate_attachments           = false
    require_attachment_acceptance = false
  }

  segments {
    name                          = "sharedServices"
    description                   = "Shared Services Segment"
    isolate_attachments           = false
    require_attachment_acceptance = false
  }

  segments {
    name                          = "staging"
    description                   = "Staging Segment"
    isolate_attachments           = false
    require_attachment_acceptance = false
  }

  attachment_policies {
    rule_number     = "101"
    condition_logic = "or"
    conditions {
      type = "any"
    }
    action {
      association_method = "tag"
      tag_value_of_key   = "Segment"
    }
  }

   attachment_policies {
    rule_number     = "100"
    condition_logic = "or"
    conditions {
      type     = "tag-value"
      operator = "equals"
      key      = "Segment"
      value    = "inspection"
    }
    action {
      add_to_network_function_group = "inspection"
    }
  }

  # segment_actions {
  #   action  = "send-via"
  #   segment = "production"
  #   when_sent_to {
  #     segments = ["hybrid"]
  #   }
  #   via {
  #     network_function_groups = ["inspection"]
  #   }
  # }

  # segment_actions {
  #   action  = "send-via"
  #   segment = "production"
  #   when_sent_to {
  #     segments = ["sharedServices"]
  #   }
  #   via {
  #     network_function_groups = ["inspection"]
  #   }
  # }

  # segment_actions {
  #   action  = "send-via"
  #   segment = "hybrid"
  #   when_sent_to {
  #     segments = ["sharedServices"]
  #   }
  #   via {
  #     network_function_groups = ["inspection"]
  #   }
  # }

  # segment_actions {
  #   action  = "send-via"
  #   segment = "staging"
  #   when_sent_to {
  #     segments = ["hybrid"]
  #   }
  #   via {
  #     network_function_groups = ["inspection"]
  #   }
  # }

  # segment_actions {
  #   action  = "send-via"
  #   segment = "staging"
  #   when_sent_to {
  #     segments = ["sharedServices"]
  #   }
  #   via {
  #     network_function_groups = ["inspection"]
  #   }
  # }
}



resource "aws_networkmanager_core_network" "core_network" {
  global_network_id    = aws_networkmanager_global_network.global_network.id
  description          = var.core_network_description
  create_base_policy   = false
}

resource "aws_networkmanager_core_network_policy_attachment" "policy_attachment" {
  core_network_id = aws_networkmanager_core_network.core_network.id
  policy_document = data.aws_networkmanager_core_network_policy_document.core_network_policy.json
}
