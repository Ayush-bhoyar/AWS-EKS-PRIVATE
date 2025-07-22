🛡️ Private EKS Cluster with Terraform — README


This project provisions a private Amazon EKS (Elastic Kubernetes Service) cluster using Terraform. The setup includes:

Custom VPC with public and private subnets

NAT Gateway for private subnet internet access

Internet Gateway for public subnet

Bastion Host for accessing private nodes securely

Private EKS Cluster with EC2-managed Node Group

Secure IAM roles and policies

Kubernetes access limited to internal components via Bastion

Project structure

eks-project/
├── modules/
│   ├── vpc/
│   ├── eks/
│   ├── bastion/
│   └── iam/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
└── README.md


🔧 Features
📦 Fully private EKS with no public endpoint

🔐 IAM-based access control for EKS

🧰 Bastion Host setup for SSH/kubectl access

🌐 NAT Gateway for private subnet outbound access

🔁 Modular Terraform structure

🚫 No public IPs on worker nodes



Prerequisites
AWS CLI & credentials configured (aws configure)

Terraform v1.3+ installed

A key pair for SSH access to Bastion (already created in AWS EC2 → Key Pairs)
