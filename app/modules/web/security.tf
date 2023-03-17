##############################################################################
# Amazon EC2 Service :: Web Server 보안그룹
##############################################################################
# Web Server :: 보안그룹
resource "aws_security_group" "web" {
  count = var.create ? 1 : 0

  name = format("%s-%s-%s", var.svr_nm, var.env, "web")
  vpc_id = var.vpc_id

  tags = {
    Name = format("%s-%s-%s", var.svr_nm, var.env, "web")
    Environments = var.env
  }
}

# Web Server 보안그룹 :: ingress rule
resource "aws_security_group_rule" "web_ingress_rules" {
  count = var.create ? length(var.web_ingress_rules) : 0

  security_group_id = aws_security_group.web.0.id
  type = "ingress"
  description = var.rules[var.web_ingress_rules[count.index]][3]

  from_port = var.rules[var.web_ingress_rules[count.index]][0]
  to_port   = var.rules[var.web_ingress_rules[count.index]][1]
  protocol  = var.rules[var.web_ingress_rules[count.index]][2]
  cidr_blocks = var.ports.all_ips
}

# Web Server  보안그룹 :: egress rule
resource "aws_security_group_rule" "web_egress_rules" {
  type = "egress"
  security_group_id = aws_security_group.web.0.id

  from_port = var.ports.any_port
  to_port = var.ports.any_port
  protocol = var.ports.any_protocol
  cidr_blocks = var.ports.all_ips
}

##############################################################################
# Amazon EC2 Service :: WAS Server 보안그룹
##############################################################################
# WAS Server :: 보안그룹
resource "aws_security_group" "was" {
  count = var.create ? 1 : 0

  name = format("%s-%s-%s", var.svr_nm, var.env, "was")
  vpc_id = var.vpc_id

  tags = {
    Name = format("%s-%s-%s", var.svr_nm, var.env, "was")
    Environments = var.env
  }
}

# WAS Server 보안그룹 :: ingress rule
resource "aws_security_group_rule" "was_ingress_rules" {
  count = var.create ? length(var.was_ingress_rules) : 0

  security_group_id = aws_security_group.was.0.id
  type = "ingress"
  description = var.rules[var.was_ingress_rules[count.index]][3]

  from_port = var.rules[var.was_ingress_rules[count.index]][0]
  to_port   = var.rules[var.was_ingress_rules[count.index]][1]
  protocol  = var.rules[var.was_ingress_rules[count.index]][2]
  cidr_blocks = var.ports.all_ips
}

# WAS Server  보안그룹 :: egress rule
resource "aws_security_group_rule" "was_egress_rules" {
  type = "egress"
  security_group_id = aws_security_group.was.0.id

  from_port = var.ports.any_port
  to_port = var.ports.any_port
  protocol = var.ports.any_protocol
  cidr_blocks = var.ports.all_ips
}

##############################################################################
# Amazon EC2 Service :: RDS 보안그룹
##############################################################################
# RDS :: 보안그룹
resource "aws_security_group" "rds" {
  count = var.create ? 1 : 0

  name = format("%s-%s-%s", var.svr_nm, var.env, "rds")
  vpc_id = var.vpc_id

  tags = {
    Name = format("%s-%s-%s", var.svr_nm, var.env, "rds")
    Environments = var.env
  }
}

# RDS 보안그룹 :: ingress rule
resource "aws_security_group_rule" "rds_ingress_rules" {
  count = var.create ? length(var.rds_ingress_rules) : 0

  security_group_id = aws_security_group.rds.0.id
  type = "ingress"
  description = var.rules[var.rds_ingress_rules[count.index]][3]

  from_port = var.rules[var.rds_ingress_rules[count.index]][0]
  to_port   = var.rules[var.rds_ingress_rules[count.index]][1]
  protocol  = var.rules[var.rds_ingress_rules[count.index]][2]
  cidr_blocks = var.ports.all_ips
}

# RDS 보안그룹 :: egress rule
resource "aws_security_group_rule" "rds_egress_rules" {
  count = var.create ? length(var.rds_ingress_rules) : 0

  security_group_id = aws_security_group.rds.0.id
  type = "egress"
  description = var.rules[var.rds_ingress_rules[count.index]][3]

  from_port = var.rules[var.rds_ingress_rules[count.index]][0]
  to_port   = var.rules[var.rds_ingress_rules[count.index]][1]
  protocol  = var.rules[var.rds_ingress_rules[count.index]][2]
  cidr_blocks = var.ports.all_ips
}