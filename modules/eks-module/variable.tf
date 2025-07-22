variable "cluster_name" {
  type = string
}

variable "eks_role_arn" {
  type = string

}

variable "node_role_arn" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
  
}

variable "bastion_host_sg_id" {
  type = string
}

variable "vpc_id" {
  type = string
}
