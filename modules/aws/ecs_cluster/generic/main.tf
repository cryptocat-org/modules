# kala
module "label" {
  source = "git::ssh://git@github.com/cryptocat-org/modules.git?ref=modules/global/label/v1.0.0"
  context = module.this.context
}

module "ecs_cluster" {
  # https://github.com/terraform-aws-modules/terraform-aws-ecs
  source  = "terraform-aws-modules/ecs/aws//modules/cluster"
  version = "5.12.0"

  # ECS Cluster Name
  cluster_name = module.label.id

  # Disable root module default Fargate provider
  default_capacity_provider_use_fargate = var.default_capacity_provider_use_fargate
  # Capacity provider
  fargate_capacity_providers = var.enable_fargate_capacity_provider ? var.fargate_capacity_providers : {}

  # Autoscaling capacity provider definitions to create for the cluster
  autoscaling_capacity_providers = local.autoscaling_capacity_providers

  tags = module.label.tags
}

module "autoscaling" {
  # https://github.com/terraform-aws-modules/terraform-aws-autoscaling/
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "8.0.0"

  create = var.enable_ec2_capacity_provider

  # Autoscaling capacity providers
  for_each = local.selected_instance_config

  # Autoscaling name
  name            = "${module.label.id}-${each.key}"
  use_name_prefix = false

  # Launch Template name
  launch_template_name            = "${module.label.id}-${each.key}-lt"
  launch_template_description     = "Launch template ${module.label.id}"
  launch_template_use_name_prefix = false

  # IAM role name
  iam_role_name            = "${module.label.id}-${each.key}-role"
  iam_role_description     = "ECS role for ${module.label.id}"
  iam_role_use_name_prefix = false

  # SSH key
  key_name = var.key_name

  # Launch template version
  update_default_version  = true
  launch_template_version = var.launch_template_version

  # A list of subnet IDs to launch resources in
  vpc_zone_identifier = var.vpc_zone_identifier
  # Controls how health checking is done
  health_check_type = var.health_check_type

  # Autoscaling group size
  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  # Determines whether the `desired_capacity` value is ignored after initial apply
  ignore_desired_capacity_changes = var.ignore_desired_capacity_changes

  # The AMI from which to launch the instance
  image_id = jsondecode(data.aws_ssm_parameter.ecs_optimized_ami.value)["image_id"]

  # Instance type. If Instance Requirements is defined then can't use instance_type
  instance_type = length(each.value.instance_requirements) > 0 ? null : each.value.instance_type

  # User Data
  user_data = base64encode(each.value.user_data)

  # Spot instances
  use_mixed_instances_policy = each.value.use_mixed_instances_policy
  mixed_instances_policy     = each.value.mixed_instances_policy
  instance_requirements      = each.value.instance_requirements

  # Security group for EC2 instances
  security_groups = [module.autoscaling_sg.security_group_id]

  # How the instances in the Auto Scaling Group should be terminated
  termination_policies = var.termination_policies

  # Create EC2 Instance Profile
  create_iam_instance_profile = var.create_iam_instance_profile

  # Define EC2 Instance role policies
  iam_role_policies = var.iam_role_policies

  # True since https://github.com/hashicorp/terraform-provider-aws/issues/12582
  autoscaling_group_tags = var.autoscaling_group_tags

  # Required for  managed_termination_protection = "ENABLED"
  protect_from_scale_in = var.protect_from_scale_in

  tags = module.label.tags
}

# Security Group to assing to Autoscaling Launch Template
module "autoscaling_sg" {
  # https://github.com/terraform-aws-modules/terraform-aws-security-group
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.2.0"

  create = var.enable_ec2_capacity_provider

  name            = "${module.label.id}-asg-sg"
  use_name_prefix = false
  description     = "Autoscaling group security group for ${module.label.id}"

  # where to create security group
  vpc_id = var.vpc_id

  # CIDR range to use on all ingress rules
  ingress_cidr_blocks = var.ingress_cidr_blocks

  # Default allow SSH and Load Balancer incoming
  ingress_rules = var.ingress_rules

  # Default allow all outgoing
  egress_rules = var.egress_rules

  tags = module.label.tags
}
