################################################################################
# Capacity Providers
################################################################################

variable "default_capacity_provider_use_fargate" {
  description = "Determines whether to use Fargate or autoscaling for default capacity provider strategy"
  type        = bool
  default     = true

  validation {
    condition = (var.default_capacity_provider_use_fargate == true && var.enable_fargate_capacity_provider == true) || var.default_capacity_provider_use_fargate == false
    error_message = "Can't use Fargate as default capacity provider, Fargate is not supported!"
  }
}

variable "enable_ec2_capacity_provider" {
  description = "Determines if to use autoscaling capacity provider strategy"
  type        = bool
  default     = false
}

variable "enable_fargate_capacity_provider" {
  description = "Determines if to use Fargate capacity provider strategy"
  type        = bool
  default     = true
}

variable "fargate_capacity_providers" {
  description = "Map of Fargate capacity provider definitions to use for the cluster"
  type = map(any)
  default = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
        base   = 20
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }
}

################################################################################
# Autoscaling group Custom
################################################################################

variable "capacity_provider" {
  description = "User input for capacity providers. Options can include \"on-demand\", \"spot\" or any custom value"
  type        = string
  default     = "on-demand"
}

variable "instance_type" {
  description = "Instance type for capacity provider."
  type        = string
  default     = "t3.medium"
}

variable "on_demand_allocation_strategy" {
  description = "Allocation strategy for on-demand instances. Use lowest-price for cost-efficiency, as it selects the cheapest On-Demand instance types available in the chosen instance pool."
  type        = string
  default     = "lowest-price"
}

variable "on_demand_base_capacity" {
  description = "Base capacity for on-demand instances. Set this to match the minimum baseline capacity required for your workload that cannot tolerate interruptions, such as critical real-time applications or steady-state services."
  type        = number
  default     = 1
}

variable "on_demand_percentage_above_base_capacity" {
  description = "Percentage above base capacity for on-demand instances. 0% for workloads tolerant of interruptions, maximizing Spot Instance usage and reducing costs."
  type        = number
  default     = 80
}

variable "spot_allocation_strategy" {
  description = "Allocation strategy for spot instances. Use price-capacity-optimized for workloads that need high availability but then spot_instance_pools can't be used"
  type        = string
  default     = "lowest-price"
  #  default     = "price-capacity-optimized"
}

variable "spot_instance_pools" {
  description = "Number of spot instance pools. A higher number increases the diversity of Spot capacity pools the Auto Scaling Group can consider, reducing the chance of running out of Spot capacity."
  type        = number
  default     = 5
}

variable "instance_requirements" {
  description = "Override the instance type in the Launch Template with instance types that satisfy the requirements. If Instance Requirements is defined then can't use instance_type"
  type        = map(any)
  default = {
    configuration = {
      excluded_instance_types = ["t2*", "r*", "d*", "g*", "i*", "z*", "x*"]
      vcpu_count = {
        min = 2
        max = 4
      }
      memory_mib = {
        min = 8192
        max = 16384
      }
    }
  }
}

variable "user_data_append" {
  description = "Additional user data to append to the default ECS configuration."
  type        = string
  default     = ""
}

variable "autoscaling_managed_termination_protection" {
  description = "Managed termination protection for auto-scaling groups."
  type        = string
  default     = "ENABLED"
}

variable "autoscaling_maximum_scaling_step_size" {
  description = "Maximum scaling step size for managed scaling."
  type        = number
  default     = 5
}

variable "autoscaling_minimum_scaling_step_size" {
  description = "Minimum scaling step size for managed scaling."
  type        = number
  default     = 1
}

variable "autoscaling_status" {
  description = "Managed scaling status."
  type        = string
  default     = "ENABLED"
}

variable "on_demand_autoscaling_target_capacity" {
  description = "Target capacity for on-demand auto-scaling."
  type        = number
  default     = 60
}

variable "spot_autoscaling_target_capacity" {
  description = "Target capacity for spot auto-scaling."
  type        = number
  default     = 90
}

variable "on_demand_autoscaling_weight" {
  description = "Weight for default capacity provider strategy for on-demand."
  type        = number
  default     = 60
}

variable "spot_autoscaling_weight" {
  description = "Weight for default capacity provider strategy for spot."
  type        = number
  default     = 40
}

variable "on_demand_autoscaling_base" {
  description = "Base tasks for default capacity provider strategy for on-demand."
  type        = number
  default     = 20
}

################################################################################
# Autoscaling group
################################################################################

variable "ecs_optimized_ami_name" {
  description = "The SSM parameter name for the ECS optimized AMI"
  default     = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended"
}

variable "min_size" {
  description = "The minimum size of the autoscaling group"
  type        = number
  default     = null
}

variable "max_size" {
  description = "The maximum size of the autoscaling group"
  type        = number
  default     = null
}

variable "desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the autoscaling group"
  type        = number
  default     = null
}

variable "launch_template_version" {
  description = "Launch template version. Can be version number, `$Latest`, or `$Default`"
  type        = string
  default     = "$Latest"
}

variable "ignore_desired_capacity_changes" {
  description = "Determines whether the `desired_capacity` value is ignored after initial apply"
  type        = bool
  default     = true
}

variable "create_iam_instance_profile" {
  description = "Determines whether an IAM instance profile is created or to use an existing IAM instance profile"
  type        = bool
  default     = true
}

variable "iam_role_policies" {
  description = "IAM policies to attach to the IAM role"
  type        = map(string)
  default = {
    AmazonEC2ContainerServiceforEC2Role = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
    AmazonSSMManagedInstanceCore        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}

variable "autoscaling_group_tags" {
  description = "A map of additional tags to add to the autoscaling group. https://github.com/hashicorp/terraform-provider-aws/issues/12582"
  type        = map(string)
  default = {
    AmazonECSManaged = true
  }
}

variable "protect_from_scale_in" {
  description = "Allows setting instance protection. The autoscaling group will not select instances with this setting for termination during scale in events."
  type        = bool
  default     = true
}

variable "health_check_type" {
  description = "`EC2` or `ELB`. Controls how health checking is done"
  type        = string
  default     = "EC2"
}

variable "key_name" {
  description = "The key name that should be used for the instance"
  type        = string
  default     = null
}

variable "termination_policies" {
  description = "A list of policies to decide how the instances in the Auto Scaling Group should be terminated. The allowed values are `OldestInstance`, `NewestInstance`, `OldestLaunchConfiguration`, `ClosestToNextInstanceHour`, `OldestLaunchTemplate`, `AllocationStrategy`, `Default`"
  type        = list(string)
  default     = ["ClosestToNextInstanceHour"]
}

variable "vpc_zone_identifier" {
  description = "A list of subnet IDs to launch resources in. Subnets automatically determine which availability zones the group will reside. Conflicts with `availability_zones`"
  type        = list(string)
  default     = null
}

#################
# Security group
#################

variable "vpc_id" {
  description = "ID of the VPC where to create security group"
  type        = string
  default     = null
}

variable "ingress_cidr_blocks" {
  description = "List of IPv4 CIDR ranges to use on all ingress rules"
  type        = list(string)
  default     = []
}

variable "ingress_rules" {
  description = "List of ingress rules to create by name"
  type        = list(string)
  default     = []
}

variable "egress_rules" {
  description = "List of egress rules to create by name"
  type        = list(string)
  default     = ["all-all"]
}
