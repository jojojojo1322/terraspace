###################################################################################
# EKS Cluster Role
###################################################################################
# eks assume role policy document
data "aws_iam_policy_document" "cluster" {
  statement {
    sid = "EKSClusterAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

# IAM Role
resource "aws_iam_role" "cluster" {
  name = format("%s-%s", local.cluster_nm, "role")
  force_detach_policies = true
  assume_role_policy = data.aws_iam_policy_document.cluster.json

  tags = {
    Name = format("%s-%s", local.cluster_nm, "role")
    Environment = var.env
  }
}

# Amazon Policy
resource "aws_iam_role_policy_attachment" "cluster" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
  ])

  policy_arn = each.value
  role = aws_iam_role.cluster.name
}
