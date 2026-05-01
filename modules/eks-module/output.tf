# Existing
output "eks_cluster_arn"  { value = aws_eks_cluster.EKS.arn }
output "eks_cluster_name" { value = aws_eks_cluster.EKS.name }

# New — needed by root providers.tf for helm + kubectl auth
output "eks_cluster_endpoint" {
  value = aws_eks_cluster.EKS.endpoint
}
output "eks_cluster_ca" {
  value = aws_eks_cluster.EKS.certificate_authority[0].data
}

# New — the OIDC outputs for your LinkedIn demo + future IRSA
output "oidc_provider_arn" {
  value       = aws_iam_openid_connect_provider.eks_oidc.arn
  description = "Use this ARN when creating IRSA trust policies for any service account"
}
output "oidc_issuer_url" {
  value       = aws_eks_cluster.EKS.identity[0].oidc[0].issuer
  description = "OIDC issuer URL"
}
