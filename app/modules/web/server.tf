###################################################################################
# Latest Amazon Linux AMI version
###################################################################################
data "aws_ami" "linux" {
  most_recent = true

  filter {
    name = "name"
    values = [ "amzn2-ami-hvm-2.0.*" ]
  }

  filter {
    name = "root-device-type"
    values = [ "ebs" ]
  }

  filter {
    name = "virtualization-type"
    values = [ "hvm" ]
  }

  filter {
    name = "architecture"
    values = [ "x86_64" ]
  }

  owners = [ "amazon" ]
}

###################################################################################
# AutoScaling Group :: Web Server
###################################################################################
# Web Server :: Autoscaling Configuration
resource "aws_launch_configuration" "web" {
  name_prefix = format("%s-%s-%s", var.svr_nm, var.env, "web-")
  image_id = data.aws_ami.linux.id
  instance_type = var.web_instance_type
  security_groups = [aws_security_group.web.0.id]
  key_name = var.key_name

  # 오토스케일링 그룹과 함께 시작 구성을 사용할 때 필요합니다.
  lifecycle {
    create_before_destroy = true
  }
  # 설정안하면 없는 보안그룹의 ID가 설정됨
  depends_on = [aws_security_group.web]
}

# Web Server :: Autoscaling Group Create
resource "aws_autoscaling_group" "web" {
  launch_configuration = aws_launch_configuration.web.id
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns = [aws_lb_target_group.web.arn]
  health_check_type = "ELB"

  min_size = var.min_size
  max_size = var.max_size
  # ASG 배포 완료를 고려하기 전에 최소 지정된 인스턴스가 상태 확인을 통과할 때까지 기다린다.
  # min_elb_capacity = var.min_size
  # ASG 인스턴스가 정상상태가 될때까지 기다려야 하는 최대 시간
  # wait_for_capacity_timeout = "20m"
  # ASG를 교체할 때는 먼저 교체용 ASG를 생성한 후 원본만 삭제
  lifecycle {
    create_before_destroy = true
  }

  tag {
    key = "Name"
    value = format("%s-%s-%s", var.svr_nm, var.env, "web")
    propagate_at_launch = true
  }
}

###################################################################################
# AutoScaling Group :: WAS Server
###################################################################################
# WAS Server :: Autoscaling Configuration
resource "aws_launch_configuration" "was" {
  name_prefix = format("%s-%s-%s", var.svr_nm, var.env, "was-")
  image_id = data.aws_ami.linux.id
  instance_type = var.was_instance_type
  security_groups = [aws_security_group.was.0.id]
  key_name = var.key_name

  # 오토스케일링 그룹과 함께 시작 구성을 사용할 때 필요합니다.
  lifecycle {
    create_before_destroy = true
  }
  # 설정안하면 없는 보안그룹의 ID가 설정됨
  depends_on = [aws_security_group.was]
}

# WAS Server :: Autoscaling Group Create
resource "aws_autoscaling_group" "was" {
  launch_configuration = aws_launch_configuration.was.id
  vpc_zone_identifier = var.expand_subnet_ids
  target_group_arns = [aws_lb_target_group.was.arn]
  health_check_type = "ELB"

  min_size = var.min_size
  max_size = var.max_size
  # ASG 배포 완료를 고려하기 전에 최소 지정된 인스턴스가 상태 확인을 통과할 때까지 기다린다.
  # min_elb_capacity = var.min_size
  # ASG 인스턴스가 정상상태가 될때까지 기다려야 하는 최대 시간
  # wait_for_capacity_timeout = "20m"
  # ASG를 교체할 때는 먼저 교체용 ASG를 생성한 후 원본만 삭제
  lifecycle {
    create_before_destroy = true
  }

  tag {
    key = "Name"
    value = format("%s-%s-%s", var.svr_nm, var.env, "was")
    propagate_at_launch = true
  }
}

###################################################################################
# Autoscaling Schedule :: Web Server
###################################################################################
# Autoscaling Schedule :: Start (업무시간에 확장처리)
resource "aws_autoscaling_schedule" "web_scale_out" {
  count = var.enable_autoscaling ? 1 : 0

  scheduled_action_name = format("%s-%s-%s", var.svr_nm, var.env, "web-scale-out")
  min_size = var.min_size
  max_size = var.max_size
  desired_capacity = var.max_size
  recurrence = "0 9 * * *"

  autoscaling_group_name = aws_autoscaling_group.web.name
}

# Autoscaling Schedule :: End (업무종료시간에 축소처리)
resource "aws_autoscaling_schedule" "web_scale_in" {
  count = var.enable_autoscaling ? 1 : 0

  scheduled_action_name = format("%s-%s-%s", var.svr_nm, var.env, "web-scale-in")
  min_size = var.min_size
  max_size = var.min_size
  desired_capacity = var.min_size
  recurrence = "0 18 * * *"

  autoscaling_group_name = aws_autoscaling_group.web.name
}

###################################################################################
# Autoscaling Schedule :: WAS Server
###################################################################################
# Autoscaling Schedule :: Start (업무시간에 확장처리)
resource "aws_autoscaling_schedule" "was_scale_out" {
  count = var.enable_autoscaling ? 1 : 0

  scheduled_action_name = format("%s-%s-%s", var.svr_nm, var.env, "was-scale-out")
  min_size = var.min_size
  max_size = var.max_size
  desired_capacity = var.max_size
  recurrence = "0 9 * * *"

  autoscaling_group_name = aws_autoscaling_group.was.name
}

# Autoscaling Schedule :: End (업무종료시간에 축소처리)
resource "aws_autoscaling_schedule" "was_scale_in" {
  count = var.enable_autoscaling ? 1 : 0

  scheduled_action_name = format("%s-%s-%s", var.svr_nm, var.env, "was-scale-in")
  min_size = var.min_size
  max_size = var.min_size
  desired_capacity = var.min_size
  recurrence = "0 18 * * *"

  autoscaling_group_name = aws_autoscaling_group.was.name
}

###################################################################################
# Cloudwatch Alarm :: Web Server
###################################################################################
resource "aws_cloudwatch_metric_alarm" "web_high_cpu" {
  alarm_name  = format("%s-%s-%s", var.svr_nm, var.env, "web-high-cpu")
  namespace   = "AWS/EC2"
  metric_name = "CPUUtilization"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 300
  statistic           = "Average"
  threshold           = 90
  unit                = "Percent"
}

resource "aws_cloudwatch_metric_alarm" "web_low_cpu" {
  alarm_name  = format("%s-%s-%s", var.svr_nm, var.env, "web-low-cpu")
  namespace   = "AWS/EC2"
  metric_name = "CPUCreditBalance"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }

  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  period              = 300
  statistic           = "Minimum"
  threshold           = 10
  unit                = "Count"
}

###################################################################################
# Cloudwatch Alarm :: WAS Server
###################################################################################
resource "aws_cloudwatch_metric_alarm" "was_high_cpu" {
  alarm_name  = format("%s-%s-%s", var.svr_nm, var.env, "was-high-cpu")
  namespace   = "AWS/EC2"
  metric_name = "CPUUtilization"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.was.name
  }

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 300
  statistic           = "Average"
  threshold           = 90
  unit                = "Percent"
}

resource "aws_cloudwatch_metric_alarm" "was_low_cpu" {
  alarm_name  = format("%s-%s-%s", var.svr_nm, var.env, "was-low-cpu")
  namespace   = "AWS/EC2"
  metric_name = "CPUCreditBalance"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.was.name
  }

  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  period              = 300
  statistic           = "Minimum"
  threshold           = 10
  unit                = "Count"
}
