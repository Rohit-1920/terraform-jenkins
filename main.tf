provider "aws" {
  region = "ap-south-1"
}

resource "aws_iam_role" "cbz_eks_role123" {
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
  role       = aws_iam_role.cbz_eks_role123.name
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

resource "aws_eks_cluster" "b35" {
  name     = "b35"
  role_arn = aws_iam_role.cbz_eks_role123.arn

  vpc_config {
    subnet_ids = data.aws_subnets.subnet_ids.ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]
}
