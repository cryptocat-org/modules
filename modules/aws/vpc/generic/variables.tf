variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "The primary IPv4 CIDR block for the VPC"
}

variable "eks_cluster_names" {
  description = "List of the EKS cluster names. To allow the AWS Load Balancer Controller to automatically discover the subnets that your Application Load Balancer uses, tag your subnets."
  type        = list(string)
  default     = []
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway for all subnets"
  type        = bool
  default     = true
}

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  type        = bool
  default     = true
}

variable "one_nat_gateway_per_az" {
  description = "Should be true if you want only one NAT Gateway per availability zone. Requires `var.azs` to be set, and the number of `public_subnets` created to be greater than or equal to the number of availability zones specified in `var.azs`"
  type        = bool
  default     = false
}
