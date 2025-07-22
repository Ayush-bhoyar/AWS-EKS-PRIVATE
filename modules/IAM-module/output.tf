output "eks_role_arn" {
  value = aws_iam_role.Eks_role.arn
}

output "Node_role_arn" {
  value = aws_iam_role.Node_role.arn
}


