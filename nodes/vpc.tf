# VPC
resource "aws_vpc" "k8s_vpc" {
  cidr_block = var.vpc_cidr
  tags       = var.tags
}

# IGW & NAT GW
resource "aws_internet_gateway" "k8s_igw" {
  vpc_id = aws_vpc.k8s_vpc.id
  tags   = var.tags
}

resource "aws_eip" "k8s_nat_eip" {
  domain = "vpc"
  tags   = var.tags
}

resource "aws_eip" "master_node_eip" {
  domain = "vpc"

  instance                  = aws_instance.master_node.id
  associate_with_private_ip = var.master_node_private_ip
  depends_on                = [aws_internet_gateway.k8s_igw]
}

resource "aws_nat_gateway" "k8s_nat_gateway" {
  allocation_id = aws_eip.k8s_nat_eip.id
  subnet_id     = aws_subnet.k8s_public_subnet.id
  tags          = var.tags
}

# Subnets
resource "aws_subnet" "k8s_public_subnet" {
  vpc_id                  = aws_vpc.k8s_vpc.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  tags                    = var.tags
}

resource "aws_subnet" "k8s_private_subnet" {
  vpc_id     = aws_vpc.k8s_vpc.id
  cidr_block = var.private_subnet_cidr
  tags       = var.tags
}

# Route Tables
resource "aws_route_table" "k8s_public_route_table" {
  vpc_id = aws_vpc.k8s_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8s_igw.id
  }
  tags = var.tags
}

resource "aws_route_table_association" "k8s_public_subnet_association" {
  subnet_id      = aws_subnet.k8s_public_subnet.id
  route_table_id = aws_route_table.k8s_public_route_table.id
}

resource "aws_route_table" "k8s_private_route_table" {
  vpc_id = aws_vpc.k8s_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.k8s_nat_gateway.id
  }
  tags = var.tags
}

resource "aws_route_table_association" "k8s_private_subnet_association" {
  subnet_id      = aws_subnet.k8s_private_subnet.id
  route_table_id = aws_route_table.k8s_private_route_table.id
}

# Security Groups
resource "aws_security_group" "master_node_sg" {
  vpc_id = aws_vpc.k8s_vpc.id
  name   = "master-node-sg"

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_ips]
  }

  ingress {
    description = "Allow Kubernetes API"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = [var.public_subnet_cidr,var.private_subnet_cidr]
  }

  ingress {
    description = "Allow etcd traffic"
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = [var.public_subnet_cidr,var.private_subnet_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_security_group" "worker_node_sg" {
  vpc_id = aws_vpc.k8s_vpc.id
  name   = "worker-node-sg"

  ingress {
    description     = "Allow SSH"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.master_node_sg.id]
  }

  ingress {
    description = "Allow Kubelet"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = [var.public_subnet_cidr,var.private_subnet_cidr]
  }

  ingress {
    description = "Allow NodePort Services"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = [var.ssh_ips] # Replace with your trusted IP range
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}
