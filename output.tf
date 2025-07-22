output "eks_cluster_arn" {
  value = module.EKS-module.eks_cluster_arn
}

output "bastion_host_sg_id" {
  value = module.VPC-module.bastion_host_sg_id

}

output "private_subnet_ids" {
  value = module.VPC-module.private_subnet_ids
}

output "public_subnet_ids" {
  value = module.VPC-module.public_subnet_ids
}

output "eks_cluster_name" {
  value = module.EKS-module.eks_cluster_name
  
}
