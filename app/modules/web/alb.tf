###################################################################################
# Application Load Balancer :: Web Server
###################################################################################
# ALB create
resource "aws_lb" "alb" {
  name = format("%s-%s-%s", var.svr_nm, var.env, "alb")

  internal = false
  load_balancer_type = "application"
  subnets = var.public_subnet_ids
  security_groups = [aws_security_group.web.0.id]

  tags = {
    Name = format("%s-%s-%s", var.svr_nm, var.env, "alb")
  }
}

# ALB listener
resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.alb.arn
  port = var.ports.http_port
  protocol = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code = 404
    }
  }
}

# ALB Listener rule
resource "aws_lb_listener_rule" "web" {
  listener_arn = aws_lb_listener.web.arn
  priority = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# ALB Target Group
resource "aws_lb_target_group" "web" {
  name = format("%s-%s-%s", var.svr_nm, var.env, "alb")

  port = var.ports.http_port
  protocol = "HTTP"
  vpc_id = var.vpc_id

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

###################################################################################
# Network Load Balancer :: WAS Server
###################################################################################
# ALB create
resource "aws_lb" "nlb" {
  name = format("%s-%s-%s", var.svr_nm, var.env, "nlb")

  internal = true
  load_balancer_type = "network"
  subnets = var.private_subnet_ids

  tags = {
    Name = format("%s-%s-%s", var.svr_nm, var.env, "nlb")
  }
}

# ALB Target Group
resource "aws_lb_target_group" "was" {
  name = format("%s-%s-%s", var.svr_nm, var.env, "nlb")
  port = var.ports.was_port
  protocol = "TCP"
  vpc_id = var.vpc_id
  target_type = "instance"
}

# ALB listener
resource "aws_lb_listener" "was" {
  load_balancer_arn = aws_lb.nlb.arn
  port = var.ports.was_port
  protocol = "TCP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.was.arn
  }
}

# NLB Target Group Attachment
resource "aws_lb_target_group_attachment" "was" {
  count = aws_autoscaling_group.was.min_size

  target_group_arn = aws_lb_target_group.was.arn
  target_id = element(data.aws_instances.was.ids, count.index)

  depends_on = [ data.aws_instances.was ]
}

# Load the aws_instances data
data "aws_instances" "was" {
  instance_tags = {
    "aws:autoscaling:groupName" = aws_autoscaling_group.was.name
  }
  depends_on = [ aws_launch_configuration.was ]
}