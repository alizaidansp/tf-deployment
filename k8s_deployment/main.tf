# Reusable Modules

# VPC Module (reused from original)
module "vpc" {
  source               = "../laravel-ec2-deployment/modules/vpc"
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

# RDS Module (reused from original)
module "rds" {
  source            = "../laravel-ec2-deployment/modules/rds"
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.private_subnet_ids
  security_group_id = module.security_group.rds_sg_id  # References new SG module
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
  multi_az          = true
}

# New Modules

# Security Group Module (new for EKS)
module "security_group" {
  source = "./modules/security_group"
  vpc_id = module.vpc.vpc_id
}

# ALB Module (new for EKS)
module "alb" {
  source            = "./modules/alb"
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.public_subnet_ids
  security_group_id = module.security_group.alb_sg_id
  target_group_port = var.target_group_port 
}

# IAM Module
module "iam" {
source = "./modules/iam"
  cluster_name       = var.cluster_name


}

# EKS Module (new)
module "eks" {
  source             = "./modules/eks"
  cluster_name       = "laravel-eks-cluster"
  cluster_version    = "1.27"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.security_group.eks_sg_id]
  
  node_groups = {
    general = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1
      instance_type    = "t3.medium"
      iam_role_arn     = module.eks.node_role_arn  # Output from the eks module
    }
  }
}


