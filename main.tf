```hcl
provider "aws" {
  region     = "us-east-1"  # Replace with your desired AWS region
}

resource "aws_iam_role" "cbz_eks_role" {
    name = "cbz-eks-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cbz_eks_role.name
}

data "aws_vpc" "my_vpc" {
    default = true
}

data "aws_subnets" "subnet_ids" {
    filter {
        name = "vpc-id"
        values = [data.aws_vpc.my_vpc.id]
    }
}

resource "aws_eks_cluster" "my_cluster" {
    name = "my-cluster"
    role_arn = aws_iam_role.cbz_eks_role.arn
    vpc_config {
        subnet_ids = [data.aws_subnets.subnet_ids.id]
  }

    depends_on = [
        aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]
}












provider "aws" {
  region = "ap-south-1"
}

resource "aws_iam_role" "cbz_eks_role" {
  name = "cbz-eks-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "sts:AssumeRole",
        "sts:TagSession"
      ]
      Effect = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cbz_eks_role.name
}

data "aws_vpc" "my_vpc" {
  default = true
}

data "aws_subnets" "subnet_ids" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.my_vpc.id]
  }
}

resource "aws_eks_cluster" "my_cluster" {
  name     = "my-cluster"
  role_arn = aws_iam_role.cbz_eks_role.arn

  vpc_config {
    subnet_ids = data.aws_subnets.subnet_ids.ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]
}



resource "aws_iam_role" "eks_node_role" {
  name = "cbz-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# EKS Managed Node Group
resource "aws_eks_node_group" "my_node_group" {
  cluster_name    = aws_eks_cluster.my_cluster.name
  node_group_name = "my-cluster-nodegroup"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = data.aws_subnets.subnet_ids.ids

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  # Use the flexible c7i instance type you requested
  instance_types = ["c7i-flex.large"]

  ami_type = "AL2023_x86_64_STANDARD"   # change if you need a different architecture/AMI

  disk_size = 20

  capacity_type = "ON_DEMAND"

  tags = {
    Name = "my-cluster-nodegroup"
  }

  depends_on = [
    aws_eks_cluster.my_cluster,
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
  ]
}
```
