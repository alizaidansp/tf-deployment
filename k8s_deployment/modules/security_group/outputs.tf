output "eks_sg_id" {
  value = aws_security_group.eks_cluster.id
}

output "alb_sg_id" {
  value = aws_security_group.alb.id
}

output "rds_sg_id" {
  value = aws_security_group.rds.id
}