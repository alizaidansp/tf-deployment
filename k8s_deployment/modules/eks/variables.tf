variable "cluster_name" { type = string }
variable "cluster_version" { type = string }
variable "vpc_id" { type = string }
variable "subnet_ids" { type = list(string) }
variable "security_group_ids" { type = list(string) }
variable "node_groups" {
  description = "Map of EKS node group configurations"
  type = map(object({
    desired_capacity = number
    max_capacity     = number
    min_capacity     = number
    instance_type    = string
    iam_role_arn     = string
  }))
  default = {}
}