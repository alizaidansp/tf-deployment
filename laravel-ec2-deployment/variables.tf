variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

# variable "aws_profile" {
#   description = "AWS CLI profile"
#   type        = string
# }

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b"]
}

# variable "ssh_key_name" {
#   description = "SSH key name for EC2"
#   type        = string
# }

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "laraveldb"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
  default     = "ali-amalitech-terraform-ec2-state-bucket"
}