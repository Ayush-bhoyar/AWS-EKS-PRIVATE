output "public_subnet_ids" {
  value=aws_subnet.public_subnet[*].id
}


output "private_subnet_ids" {
  value=aws_subnet.private_subnet[*].id
}

output "Main_vpc_id" {
  value = aws_vpc.Main.id
}

output "bastion_host_sg_id" {
  value = aws_security_group.bastion-host-sg.id
}

