output "cluster_name" {
  description = "EKS Cluster Name"
  value       = aws_eks_cluster.orderflow_cluster.name
}

output "cluster_endpoint" {
  description = "EKS Cluster API Endpoint"
  value       = aws_eks_cluster.orderflow_cluster.endpoint
}

output "cluster_arn" {
  description = "EKS Cluster ARN"
  value       = aws_eks_cluster.orderflow_cluster.arn
}

output "node_group_arn" {
  description = "EKS Node Group ARN"
  value       = aws_eks_node_group.orderflow_nodes.arn
}

