output "eks_cluster_arn" {
  value = aws_eks_cluster.EKS.arn
}

output "eks_cluster_name" {
  value = aws_eks_cluster.EKS.name
}

