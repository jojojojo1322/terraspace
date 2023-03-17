################################################################################
# IAM Role for Flow Log
################################################################################
data "aws_iam_policy_document" "flow_log_cloudwatch_assume_role" {
  statement {
    sid = "AWSVPCFlowLogsAssumeRole"
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "vpc_flow_log_cloudwatch" {
  name_prefix = local.cluster_nm
  assume_role_policy = data.aws_iam_policy_document.flow_log_cloudwatch_assume_role.json

  tags = {
    Name = format("%s-%s",  local.cluster_nm, "flow-log-role")
    Environment = var.env
  }
}

resource "aws_iam_role_policy_attachment" "vpc_flow_log_cloudwatch" {
  role = aws_iam_role.vpc_flow_log_cloudwatch.name
  policy_arn = aws_iam_policy.vpc_flow_log_cloudwatch.arn
}

data "aws_iam_policy_document" "vpc_flow_log_cloudwatch" {
  statement {
    sid = "AWSVPCFlowLogsPushToCloudWatch"
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "vpc_flow_log_cloudwatch" {
  name_prefix = local.cluster_nm
  policy = data.aws_iam_policy_document.vpc_flow_log_cloudwatch.json
}
