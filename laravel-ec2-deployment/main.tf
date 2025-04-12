# for file in *.tf; do echo "===== $file =====" >> output.txt; cat "$file" >> output.txt; echo "" >> output.txt; done

# VPC Module
module "vpc" {
  source               = "./modules/vpc"
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

# Security Group Module
module "security_group" {
  source = "./modules/security_group"
  vpc_id = module.vpc.vpc_id
}

# IAM Module
module "iam" {
  source    = "./modules/iam"
  role_name = "lamp-ec2"
  region    = var.aws_region
}

# ALB Module
module "alb" {
  source            = "./modules/alb"
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.public_subnet_ids
  security_group_id = module.security_group.alb_sg_id
  target_group_port = 80
}

# EC2 Module
module "ec2" {
  source               = "./modules/ec2"
  subnet_ids           = module.vpc.private_subnet_ids
  security_group_id    = module.security_group.ec2_sg_id
  # ssh_key_name         = var.ssh_key_name
  iam_instance_profile = module.iam.instance_profile_name  # Updated to use IAM module output
  alb_target_group_arn = module.alb.target_group_arn
  db_host              = module.rds.db_endpoint
  db_password        = var.db_password
}

# RDS Module
module "rds" {
  source            = "./modules/rds"
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.private_subnet_ids
  security_group_id = module.security_group.rds_sg_id
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
  multi_az          = true
}

