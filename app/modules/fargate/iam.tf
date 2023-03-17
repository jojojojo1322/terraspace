###################################################################################
# IAM Role 생성 (Fargate)
###################################################################################
data "aws_iam_policy_document" "fargate" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "eks-fargate-pods.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "fargate" {
  name = format("%s-%s", local.cluster_nm, "fargate")
  force_detach_policies = true
  assume_role_policy = data.aws_iam_policy_document.fargate.json
}

# Amazon Policy
resource "aws_iam_role_policy_attachment" "fargate" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController",
  ])

  policy_arn = each.value
  role = aws_iam_role.fargate.name
}
