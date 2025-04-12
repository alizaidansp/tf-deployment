variable "subnet_ids" {
  description = "List of subnet IDs for the Auto Scaling Group"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for EC2 instances"
  type        = string
}

# variable "ssh_key_name" {
#   description = "SSH key name for EC2 instances"
#   type        = string
# }

variable "iam_instance_profile" {
  description = "IAM instance profile name for EC2 instances"
  type        = string
}

variable "alb_target_group_arn" {
  description = "ARN of the ALB target group"
  type        = string
}

variable "db_host" {
  description = "RDS database host endpoint"
  type        = string
}


variable "db_username" {
  description = "Database username"
  type        = string
  
}
variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}