output "vpc_name" {
  description = "Created VPC name"
  value       = module.label.id
}

output "account_id" {
  description = "AWS Account ID"
  value       = data.aws_caller_identity.this.account_id
}

output "vpc_id" {
  description = "Created VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  value = module.vpc.vpc_cidr_block
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}
