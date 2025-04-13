# Reusable Modules

# VPC Module (reused from original)
module "vpc" {
  source               = "../laravel-ec2-deployment/modules/vpc"
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones


  #  Tagging (Essential for EKS Discovery)
  
   public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
}

}


# New Modules

# Security Group Module (new for EKS)
module "security_group" {
  source = "./modules/security_group"
  vpc_id = module.vpc.vpc_id
}


# IAM Module
module "iam" {
source = "./modules/iam"
cluster_name       = var.cluster_name


}

# EKS Module (new)
module "eks" {
  source             = "./modules/eks"
  cluster_name       = "laravel-eks-cluster-2"
  cluster_version    = "1.27"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.security_group.eks_sg_id]
  eks_cluster_role_arn = module.iam.eks_cluster_role_arn  # Correct module reference
  eks_node_role_arn = module.iam.eks_node_role_arn  # Correct module reference
  worker_security_group_id = module.security_group.worker_security_group_id

  
  node_groups = {
    general = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1
      instance_type    = "t3.medium"
      iam_role_arn     = module.iam.eks_node_role_arn  # Match the output name
      additional_security_group_ids = [module.security_group.worker_security_group_id]  # Add worker SG
    }
  }
}





# Get worker node security group
data "aws_security_group" "worker" {
  name   = "eks-cluster-sg"  # Match your EKS worker SG name
  vpc_id = module.vpc.vpc_id
  depends_on = [module.security_group]
}



