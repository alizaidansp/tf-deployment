variable "role_name" {
  description = "Name prefix for the IAM role and instance profile"
  type        = string
  default     = "lamp-ec2"
}

variable "region" {
  description = "AWS region for resource ARNs"
  type        = string
  default     = "eu-west-1"
}