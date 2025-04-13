output "eks_sg_id" {
  value = aws_security_group.eks_cluster.id
}




output "worker_security_group_id" {
  value = aws_security_group.workers.id
}