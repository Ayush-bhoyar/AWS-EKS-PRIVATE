

module "VPC-module" {
  source               = "./modules/VPC-module"
  public_subnet_count  = var.public_subnet_count
  private_subnet_count = var.private_subnet_count
  main_cidr_block      = var.main_cidr_block
  bastion_key_name     = var.bastion_key_name

}

module "IAM-module" {
  source = "./modules/IAM-module"

}


module "EKS-module" {
  source             = "./modules/eks-module"
  vpc_id             = module.VPC-module.Main_vpc_id
  eks_role_arn       = module.IAM-module.eks_role_arn
  node_role_arn      = module.IAM-module.Node_role_arn
  cluster_name       = var.cluster_name
  private_subnet_ids = module.VPC-module.private_subnet_ids
  bastion_host_sg_id = module.VPC-module.bastion_host_sg_id

}
