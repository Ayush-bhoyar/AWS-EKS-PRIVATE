variable "main_cidr_block" {
  type = string
}

variable "public_subnet_count" {
  type = number
}

variable "private_subnet_count" {
  type = number
}

variable "bastion_key_name" {
  type        = string
  description = "Name of the EC2 key pair for SSH access to bastion"
}
