locals {

  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  public_subnet_tags = merge(
    # required tags to make ALB ingress work https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html
    {
      "Subnet"      = "public"
      "subnet-type" = "public"
      "kubernetes.io/role/elb" : 1
    },

    # The usage of the specific kubernetes.io/cluster/* resource tags below are required
    # for EKS and Kubernetes to discover and manage networking resources
    # https://aws.amazon.com/premiumsupport/knowledge-center/eks-vpc-subnet-discovery/
    # https://github.com/kubernetes-sigs/aws-load-balancer-controller/blob/main/docs/deploy/subnet_discovery.md

    # Loop only if var.eks_cluster_names
    length(var.eks_cluster_names) > 0 ?
    {
      for name in var.eks_cluster_names :
      "kubernetes.io/cluster/${name}" => "shared"
    } : {}
  )

  private_subnet_tags = merge(
    # required tags to make ALB ingress work https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html
    {
      "Subnet"      = "private"
      "subnet-type" = "private"
      "kubernetes.io/role/internal-elb" : 1
    },

    # The usage of the specific kubernetes.io/cluster/* resource tags below are required
    # for EKS and Kubernetes to discover and manage networking resources
    # https://aws.amazon.com/premiumsupport/knowledge-center/eks-vpc-subnet-discovery/
    # https://github.com/kubernetes-sigs/aws-load-balancer-controller/blob/main/docs/deploy/subnet_discovery.md

    # Loop only if var.eks_cluster_names
    length(var.eks_cluster_names) > 0 ?
    {
      for name in var.eks_cluster_names :
      "kubernetes.io/cluster/${name}" => "shared"
    } : {}
  )
}
