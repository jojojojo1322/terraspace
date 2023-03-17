##############################################################################
# VPC Default 보안그룹
##############################################################################
data "aws_security_group" "default" {
  vpc_id = var.vpc_id
  name   = "default"
}

##############################################################################
# Amazon MSK Cluster 보안그룹 생성
##############################################################################
# security group :: kafka
resource "aws_security_group" "this" {
  count = var.create ? 1 : 0

  name = format("%s-%s", var.svr_nm, var.env)
  vpc_id = var.vpc_id

  tags = {
    Name = format("%s-%s", var.svr_nm, var.env)
    Environments = var.env
  }
}

# kafka 보안그룹 :: ingress rule
resource "aws_security_group_rule" "ingress_rules" {
  count = var.create ? length(var.ingress_rules) : 0

  security_group_id = aws_security_group.this.0.id
  type = "ingress"
  description = var.rules[var.ingress_rules[count.index]][3]

  from_port = var.rules[var.ingress_rules[count.index]][0]
  to_port   = var.rules[var.ingress_rules[count.index]][1]
  protocol  = var.rules[var.ingress_rules[count.index]][2]
  cidr_blocks = var.cidr_block
}

# kafka 보안그룹 :: egress rule
resource "aws_security_group_rule" "egress_rules" {
  type = "egress"
  security_group_id = aws_security_group.this.0.id

  from_port = var.ports.any_port
  to_port = var.ports.any_port
  protocol = var.ports.any_protocol
  cidr_blocks = var.ports.all_ips
}

##############################################################################
# MSK SASL & IAM Authentication
##############################################################################
# Kafka SASL/SCRAM 인증을 위한 Secret Manager
resource "aws_secretsmanager_secret" "this" {
  name = format("%s_%s_%s", "AmazonMSK", var.svr_nm, var.env)
  kms_key_id = var.kms_key_arn
}

# Secret Manager String
resource "aws_secretsmanager_secret_version" "this" {
  secret_id = aws_secretsmanager_secret.this.id
  secret_string = jsonencode({ username = "mskuser", password = "mskpass" })
}

# Secret Manager Policy
resource "aws_secretsmanager_secret_policy" "this" {
  secret_arn = aws_secretsmanager_secret.this.arn
  policy     = <<POLICY
{
  "Version" : "2012-10-17",
  "Statement" : [ {
    "Sid": "AWSKafkaResourcePolicy",
    "Effect" : "Allow",
    "Principal" : {
      "Service" : "kafka.amazonaws.com"
    },
    "Action" : "secretsmanager:getSecretValue",
    "Resource" : "${aws_secretsmanager_secret.this.arn}"
  } ]
}
POLICY
}