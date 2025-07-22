resource "aws_vpc" "Main" {
  cidr_block = var.main_cidr_block

  tags = {
    Name= "Main-vpc"
  }

}

data "aws_availability_zones" "available" {
  
}

locals {
  total_subnets = var.public_subnet_count + var.private_subnet_count
  new_bits      = ceil(log(local.total_subnets, 2))
}

resource "aws_subnet" "private_subnet" {
  count = var.private_subnet_count
  cidr_block = cidrsubnet(var.main_cidr_block, local.new_bits, count.index)
  vpc_id = aws_vpc.Main.id
  availability_zone = data.aws_availability_zones.available.names[count.index %length(data.aws_availability_zones.available.names)]
  map_public_ip_on_launch = false

  tags = {
    Name =  "Private-subnet-${count.index}"  }
}

resource "aws_subnet" "public_subnet" {
  count = var.public_subnet_count
  vpc_id = aws_vpc.Main.id
  cidr_block = cidrsubnet(var.main_cidr_block, local.new_bits, count.index +var.private_subnet_count)
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]

  tags = {
    Name =  "Public-subnet-${count.index}"  }
  
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.Main.id

tags = {
  Name= "Internet-gw"
}
}

resource "aws_eip" "NAT-EIP" {
  count = var.public_subnet_count
 
  
}
resource "aws_nat_gateway" "NAT-GW" {
  count= var.public_subnet_count
  allocation_id = aws_eip.NAT-EIP[count.index].id
  subnet_id = aws_subnet.public_subnet[count.index].id
  tags={
    Name= "NAT-GW-${count.index}"

  }
}

resource "aws_route_table" "Public-RT" {
  vpc_id = aws_vpc.Main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
}


resource "aws_route_table_association" "Public-RTA" {
  count=var.public_subnet_count
  subnet_id = aws_subnet.public_subnet[count.index].id   
  route_table_id = aws_route_table.Public-RT.id
 
}

resource "aws_route_table" "Private-RT" {
  count = var.private_subnet_count
  vpc_id = aws_vpc.Main.id
  route{
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NAT-GW[count.index % var.public_subnet_count].id
  }
}

resource "aws_route_table_association" "Private-RTA" {
  count=var.private_subnet_count
  subnet_id = aws_subnet.private_subnet[count.index].id    
  route_table_id = aws_route_table.Private-RT[count.index].id
}


resource "aws_security_group" "bastion-host-sg" {
  vpc_id = aws_vpc.Main.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["223.185.36.184/32"]  # Add your linux machine public ip from which you want to connect to bastion host#
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


