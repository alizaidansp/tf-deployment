output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}





output "node_role_arn" {
  value = var.eks_node_role_arn
}

output "worker_security_group_id" {
  value = var.worker_security_group_id
}