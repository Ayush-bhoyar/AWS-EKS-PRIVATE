resource "aws_iam_role" "Eks_role" {
  name = "EKS-ROLE"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "eks_policy_attachment" {
  name       = "EKS-Policy-Attachment"
  roles      = [aws_iam_role.Eks_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  
}

resource "aws_iam_role" "Node_role" {
  name = "NODE-ROLE"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

}
resource "aws_iam_policy_attachment" "Node_role_policy_attachment" {
  name       = "Node-Role-Policy-Attachment"
  roles      = [aws_iam_role.Node_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  
}

resource "aws_iam_policy_attachment" "Node_role_cni_policy_attachment" {
  name       = "Node-Role-CNI-Policy-Attachment"
  roles      = [aws_iam_role.Node_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  
}

resource "aws_iam_policy_attachment" "Node_role_ECR_policy_attachment" {
  name= "Node-Role-ECR-Policy-Attachment"
  roles =[aws_iam_role.Node_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

