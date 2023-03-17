###############################################################
# Local Variables
###############################################################
locals {
  cluster_nm = format("%s-%s", var.svr_nm, var.env)
}

###################################################################################
# VPC Flow Log 생성
###################################################################################
# Cloudwatch logs
resource "aws_cloudwatch_log_group" "flow_log" {
  name = "/aws/eks/${local.cluster_nm}/flow-log"
  retention_in_days = 7
  kms_key_id = aws_kms_key.eks.arn

  tags = {
    Name = "/aws/eks/${local.cluster_nm}/flow-log"
    Environment = var.env
  }
}

resource "aws_flow_log" "flow-log" {
  log_destination_type = "cloud-watch-logs"
  log_destination = aws_cloudwatch_log_group.flow_log.arn
  iam_role_arn = aws_iam_role.vpc_flow_log_cloudwatch.arn
  traffic_type = "ALL"
  vpc_id = var.vpc_id
  max_aggregation_interval = 60

  # log_destination_type = "s3"의 옵션
  # destination_options {
  #     file_format = "plain-text"
  #     hive_compatible_partitions = false
  #     per_hour_partition = false
  # }

  tags = {
    Name = format("%s-%s", local.cluster_nm, "flow-log")
    Environment = var.env
  }
}
