resource "aws_security_group" "eks_cluster_sg" {

  name        = "${var.cluster_name}-eks-cluster-sg"
  description = "Security group for EKS cluster"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [var.bastion_host_sg_id]

  }

egress {
    from_port = 0
    to_port   = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
}

}

resource "aws_eks_cluster" "EKS" {
  name= var.cluster_name
  role_arn = var.eks_role_arn
  vpc_config {
    subnet_ids = var.private_subnet_ids
    security_group_ids = [aws_security_group.eks_cluster_sg.id]
    endpoint_private_access = true
    endpoint_public_access = false
  }

  tags ={
    Name= var.cluster_name
    Environment = "Production"
  }
  }

resource "aws_eks_node_group" "eks_node_group" {
  cluster_name = var.cluster_name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn = var.node_role_arn
  subnet_ids = var.private_subnet_ids
  scaling_config {
    desired_size = 2
    max_size = 2
    min_size = 1
  }
  instance_types = ["t3.medium"]
   ami_type = "AL2023_x86_64_STANDARD"
   disk_size = 20

   tags = {
     Name = "${var.cluster_name}-node-group"
     Environment = "Production"
   }
   depends_on = [
    aws_eks_cluster.EKS
  ]
}

