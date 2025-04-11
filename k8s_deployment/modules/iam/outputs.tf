output "role_arn" {
  description = "ARN of the IAM role"
  value       = aws_iam_role.eks_cluster_role.arn
}