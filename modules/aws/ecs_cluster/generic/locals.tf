locals {
  # Autoscaling config

  # Determine selected instance configurations based on user input
  selected_instance_config = {
    for provider, config in local.instance_config :
    provider => config
    if var.enable_ec2_capacity_provider == true && provider == var.capacity_provider
  }

  instance_config = {
    # On-Demand capacity provider
    on-demand = {
      instance_type              = var.instance_type
      use_mixed_instances_policy = false
      mixed_instances_policy     = {}
      instance_requirements      = {}
      user_data                  = <<-EOT
        #!/bin/bash

        cat <<'EOF' >> /etc/ecs/ecs.config
        ECS_CLUSTER=${module.label.id}
        ECS_LOGLEVEL=debug
        ECS_CONTAINER_INSTANCE_TAGS=${jsonencode(module.label.tags)}
        ECS_ENABLE_TASK_IAM_ROLE=true
        EOF
        ${var.user_data_append}
      EOT
    }

    # Spot Instance Capacity provider
    spot = {
      instance_type              = var.instance_type
      use_mixed_instances_policy = true
      mixed_instances_policy = {
        instances_distribution = {
          on_demand_allocation_strategy            = var.on_demand_allocation_strategy
          on_demand_base_capacity                  = var.on_demand_base_capacity
          on_demand_percentage_above_base_capacity = var.on_demand_percentage_above_base_capacity
          spot_allocation_strategy                 = var.spot_allocation_strategy
          spot_instance_pools                      = var.spot_instance_pools
        }
      }
      instance_requirements = var.instance_requirements["configuration"]
      user_data             = <<-EOT
        #!/bin/bash

        cat <<'EOF' >> /etc/ecs/ecs.config
        ECS_CLUSTER=${module.label.id}
        ECS_LOGLEVEL=debug
        ECS_CONTAINER_INSTANCE_TAGS=${jsonencode(module.label.tags)}
        ECS_ENABLE_TASK_IAM_ROLE=true
        ECS_ENABLE_SPOT_INSTANCE_DRAINING=true
        EOF
        ${var.user_data_append}
      EOT
    }
  }

  # ECS Cluster config

  # Directly match the user input with the available capacity provider keys
  autoscaling_capacity_providers = {
    for provider, config in local.capacity_provider_configs :
    provider => config
    if var.enable_ec2_capacity_provider == true && provider == var.capacity_provider
  }

  capacity_provider_configs = {
    on-demand = {
      name                           = "${module.label.id}-on-demand"
      auto_scaling_group_arn         = try(module.autoscaling["on-demand"].autoscaling_group_arn, null)
      managed_termination_protection = var.autoscaling_managed_termination_protection
      managed_scaling = {
        maximum_scaling_step_size = var.autoscaling_maximum_scaling_step_size
        minimum_scaling_step_size = var.autoscaling_minimum_scaling_step_size
        status                    = var.autoscaling_status
        target_capacity           = var.on_demand_autoscaling_target_capacity
      }
      default_capacity_provider_strategy = {
        weight = var.on_demand_autoscaling_weight
        base   = var.on_demand_autoscaling_base
      }
    }
    spot = {
      name                           = "${module.label.id}-spot"
      auto_scaling_group_arn         = try(module.autoscaling["spot"].autoscaling_group_arn, null)
      managed_termination_protection = var.autoscaling_managed_termination_protection
      managed_scaling = {
        maximum_scaling_step_size = var.autoscaling_maximum_scaling_step_size
        minimum_scaling_step_size = var.autoscaling_minimum_scaling_step_size
        status                    = var.autoscaling_status
        target_capacity           = var.spot_autoscaling_target_capacity
      }
      default_capacity_provider_strategy = {
        weight = var.spot_autoscaling_weight
      }
    }
  }
}
