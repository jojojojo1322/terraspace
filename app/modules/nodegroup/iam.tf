###################################################################################
# IAM ROLE
###################################################################################
data "aws_iam_policy_document" "node" {
  statement {
    sid = "EKSNodeAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# IAM Role
resource "aws_iam_role" "node" {
  name = format("%s-%s", local.cluster_nm, "node")
  force_detach_policies = true
  assume_role_policy = data.aws_iam_policy_document.node.json
}

# Amazon Policy
resource "aws_iam_role_policy_attachment" "node" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  ])

  policy_arn = each.value
  role = aws_iam_role.node.name
}

# IAM profile
resource "aws_iam_instance_profile" "node" {
  name = format("%s-%s", local.cluster_nm, "node")
  role = aws_iam_role.node.name
}