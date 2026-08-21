# ── Unchanged ──────────────────────────────────────────────
resource "aws_security_group" "eks_cluster_sg" {
  name        = "${var.cluster_name}-eks-cluster-sg"
  description = "Security group for EKS cluster"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [var.bastion_host_sg_id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ── MODIFIED: added version = "1.30" ───────────────────────
resource "aws_eks_cluster" "EKS" {
  name     = var.cluster_name
  role_arn = var.eks_role_arn
  version  = "1.30"    # ADD THIS — needed to pin addon versions correctly

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    security_group_ids      = [aws_security_group.eks_cluster_sg.id]
    endpoint_private_access = true
    endpoint_public_access  = false
  }

  tags = {
    Name        = var.cluster_name
    Environment = "Production"
    Owner = Ayush
    Project = "Eks-terraform"
  }
}

# ── NEW: fetch OIDC TLS thumbprint ─────────────────────────
data "tls_certificate" "eks_oidc" {
  url = aws_eks_cluster.EKS.identity[0].oidc[0].issuer
}

# ── NEW: OIDC provider ─────────────────────────────────────
resource "aws_iam_openid_connect_provider" "eks_oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.EKS.identity[0].oidc[0].issuer

  tags = {
    Name = "${var.cluster_name}-oidc"
    Environment = "Production"
    Owner = Ayush
    Project = "Eks-terraform"

  }
}

# ── NEW: vpc-cni as managed addon (to enable Network Policy) 
resource "aws_eks_addon" "vpc_cni" {
  cluster_name             = aws_eks_cluster.EKS.name
  addon_name               = "vpc-cni"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  configuration_values = jsonencode({
    enableNetworkPolicy = "true"
  })

  depends_on = [aws_eks_node_group.eks_node_group]
}

# ── Unchanged ──────────────────────────────────────────────
resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 1
  }

  instance_types = ["t3.medium"]
  ami_type       = "AL2023_x86_64_STANDARD"
  disk_size      = 20

  tags = {
    Name        = "${var.cluster_name}-node-group"
    Environment = "Production"
    
    Owner = Ayush
    Project = "Eks-terraform"

  }

  depends_on = [aws_eks_cluster.EKS]
}
