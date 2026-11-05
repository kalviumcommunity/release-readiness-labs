# OrderFlow Production Infrastructure Definition
# Corrected from standalone t2.micro EC2 to AWS EKS Managed Kubernetes Cluster
# Justification: OrderFlow is a containerized microservice requiring multi-replica (3x)
# declarative rolling updates, automated health probing (/health), and service load balancing.

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# -------------------------------------------------------------------------------------------------
# Network Configuration (VPC & Subnets across multiple Availability Zones for High Availability)
# -------------------------------------------------------------------------------------------------
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "orderflow_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "orderflow-production-vpc"
    Environment = var.environment
    Project     = "OrderFlow"
    ManagedBy   = "Terraform"
  }
}

resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.orderflow_vpc.id
  cidr_block              = "10.0.${count.index + 1}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                                           = "orderflow-public-subnet-${count.index + 1}"
    Environment                                    = var.environment
    "kubernetes.io/cluster/${var.cluster_name}"   = "shared"
    "kubernetes.io/role/elb"                       = "1"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.orderflow_vpc.id

  tags = {
    Name        = "orderflow-igw"
    Environment = var.environment
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.orderflow_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "orderflow-public-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

# -------------------------------------------------------------------------------------------------
# IAM Roles for EKS Cluster & Node Group
# -------------------------------------------------------------------------------------------------
resource "aws_iam_role" "eks_cluster_role" {
  name = "orderflow-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role" "eks_node_role" {
  name = "orderflow-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_ecr_read_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

# -------------------------------------------------------------------------------------------------
# Production Kubernetes Cluster (AWS EKS)
# -------------------------------------------------------------------------------------------------
resource "aws_eks_cluster" "orderflow_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.29"

  vpc_config {
    subnet_ids              = aws_subnet.public[*].id
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]

  tags = {
    Name        = var.cluster_name
    Environment = var.environment
    Version     = var.release_version
    Project     = "OrderFlow"
    ManagedBy   = "Terraform"
  }
}

# -------------------------------------------------------------------------------------------------
# Production Managed Worker Node Group (Multi-AZ, Auto-scaling)
# -------------------------------------------------------------------------------------------------
resource "aws_eks_node_group" "orderflow_nodes" {
  cluster_name    = aws_eks_cluster.orderflow_cluster.name
  node_group_name = "orderflow-production-nodegroup"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = aws_subnet.public[*].id

  scaling_config {
    desired_size = 3
    max_size     = 5
    min_size     = 2
  }

  instance_types = [var.node_instance_type]

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_ecr_read_policy,
  ]

  tags = {
    Environment = var.environment
    Version     = var.release_version
    Project     = "OrderFlow"
    ManagedBy   = "Terraform"
  }
}
