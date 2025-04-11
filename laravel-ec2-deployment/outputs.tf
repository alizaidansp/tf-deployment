output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = module.alb.alb_dns_name
}

output "ec2_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = module.ec2.ec2_private_ip
}

output "db_endpoint" {
  description = "RDS endpoint"
  value       = module.rds.db_endpoint
}