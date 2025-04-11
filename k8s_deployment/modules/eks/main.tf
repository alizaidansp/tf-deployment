resource "aws_eks_node_group" "this" {
  for_each         = var.node_groups
  cluster_name     = aws_eks_cluster.this.name
  node_group_name  = "${var.cluster_name}-${each.key}"
  node_role_arn    = aws_iam_role.eks_node_role.arn
  subnet_ids       = var.subnet_ids
  instance_types   = [each.value.instance_type]
  
  scaling_config {
    desired_size = each.value.desired_capacity
    max_size     = each.value.max_capacity
    min_size     = each.value.min_capacity
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ecr_readonly,
  ]
}

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.cluster_version
  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }
}