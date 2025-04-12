# output "alb_dns_name" {
#   description = "DNS name of the ALB"
#   value       = module.alb.alb_dns_name
# }

output "eks_cluster_endpoint" {
  description = "Endpoint of the EKS cluster"
  value       = module.eks.cluster_endpoint
}

# output "db_endpoint" {
#   description = "RDS endpoint"
#   value       = module.rds.db_endpoint
# }

output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
  
}

output "cluster_name" {
  description = "EKS cluster name"
  value       =var.cluster_name
  
}