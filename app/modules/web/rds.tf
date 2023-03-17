###################################################################################
# Amazon EC2 서비스 생성 :: RDS Instance
# DBA가 정의해야 될 영역이며, 해당 부분은 인스턴스의 생성에 대해서만 정의한다.
###################################################################################

###################################################################################
# Amazon Aurora RDS :: Local Variables
###################################################################################
locals {
  apg_cluster_pgroup_params = [{
    name         = "rds.force_autovacuum_logging_level"
    value        = "warning"
    apply_method = "immediate"
    }, {
    name         = "rds.force_admin_logging_level"
    value        = "warning"
    apply_method = "immediate"
    }, {
    name         = "rds.enable_plan_management"
    value        = 1
    apply_method = "pending-reboot"
  }]

  apg_db_pgroup_params = [{
    name         = "shared_preload_libraries"
    value        = "auto_explain,pg_stat_statements,pg_hint_plan,pgaudit"
    apply_method = "pending-reboot"
    }, {
    name         = "log_lock_waits"
    value        = 1
    apply_method = "immediate"
    }, {
    name         = "log_statement"
    value        = "ddl"
    apply_method = "immediate"
    }, {
    name         = "log_temp_files"
    value        = 4096
    apply_method = "immediate"
    }, {
    name         = "log_min_duration_statement"
    value        = 5000
    apply_method = "immediate"
    }, {
    name         = "auto_explain.log_min_duration"
    value        = 5000
    apply_method = "immediate"
    }, {
    name         = "auto_explain.log_verbose"
    value        = 1
    apply_method = "immediate"
    }, {
    name         = "log_rotation_age"
    value        = 1440
    apply_method = "immediate"
    }, {
    name         = "log_rotation_size"
    value        = "102400"
    apply_method = "immediate"
    }, {
    name         = "rds.log_retention_period"
    value        = 10080
    apply_method = "immediate"
    }, {
    name         = "random_page_cost"
    value        = 1
    apply_method = "immediate"
    }, {
    name         = "track_activity_query_size"
    value        = 16384
    apply_method = "pending-reboot"
    }, {
    name         = "idle_in_transaction_session_timeout"
    value        = 7200000
    apply_method = "immediate"
    }, {
    name         = "statement_timeout"
    value        = 7200000
    apply_method = "immediate"
    }, {
    name         = "apg_plan_mgmt.capture_plan_baselines"
    value        = "automatic"
    apply_method = "immediate"
    }, {
    name         = "apg_plan_mgmt.use_plan_baselines"
    value        = true
    apply_method = "immediate"
    }, {
    name         = "apg_plan_mgmt.plan_retention_period"
    value        = 90
    apply_method = "pending-reboot"
    }, {
    name         = "apg_plan_mgmt.unapproved_plan_execution_threshold"
    value        = 100
    apply_method = "immediate"
  }]
}

###################################################################################
# Amazon Aurora RDS :: DB Subnet
###################################################################################
resource "aws_db_subnet_group" "rds" {
  name = format("%s-%s-%s", var.svr_nm, var.env, "sg")
  subnet_ids = var.rds_subnet_ids
  tags = {
    Name = format("%s-%s-%s", var.svr_nm, var.env, "sg")
  }
}

###################################################################################
# Amazon Aurora RDS :: IAM
###################################################################################
data "aws_partition" "current" {}

# RDS Monitoring Assume Role
data "aws_iam_policy_document" "monitoring_rds_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

# RDS Monitoring IAM role
resource "aws_iam_role" "rds_enhanced_monitoring" {
  description = "IAM Role for RDS Enhanced monitoring"
  path = "/"
  assume_role_policy  = data.aws_iam_policy_document.monitoring_rds_assume_role.json
  managed_policy_arns = ["arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"]
  tags = {
    Name = format("%s-%s-%s", var.svr_nm, var.env, "aurora-db")
  }
}

###################################################################################
# Amazon EC2 서비스 생성 :: Parameter Group
###################################################################################
# RDS Engine Version
data "aws_rds_engine_version" "family" {
  engine = "aurora-postgresql"
  version  = var.postgres_version
}

# RDS 클러스터 파라미터 그룹
resource "aws_rds_cluster_parameter_group" "aurora_cluster_parameter_group" {
  name_prefix = format("%s-%s-%s", var.svr_nm, var.env, "cluster-")
  family = data.aws_rds_engine_version.family.parameter_group_family
  description = "aurora-cluster-parameter-group"

  dynamic "parameter" {
    for_each = local.apg_cluster_pgroup_params
    iterator = pblock

    content {
      name         = pblock.value.name
      value        = pblock.value.value
      apply_method = pblock.value.apply_method
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

# RDS 인스턴스 파라미터 그룹
resource "aws_db_parameter_group" "aurora_db_parameter_group" {
  name_prefix = format("%s-%s-%s", var.svr_nm, var.env, "db-")
  family = data.aws_rds_engine_version.family.parameter_group_family
  description = "aurora-db-parameter-group"

  dynamic "parameter" {
    for_each = local.apg_db_pgroup_params
    iterator = pblock

    content {
      name         = pblock.value.name
      value        = pblock.value.value
      apply_method = pblock.value.apply_method
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

###################################################################################
# Amazon EC2 서비스 생성 :: RDS Cluster
###################################################################################
resource "aws_rds_cluster" "rds" {
  cluster_identifier        = format("%s-%s-%s", var.svr_nm, var.env, "db")
  engine                    = "aurora-postgresql"
  engine_version            = var.postgres_version
  engine_mode               = "provisioned"
  allow_major_version_upgrade = true   # 주요 엔진 버전 업데이트 허용 (default : false)
  availability_zones        = var.availability_zones
  db_subnet_group_name      = aws_db_subnet_group.rds.name
  port                      = var.port
  database_name             = null      # 자동 생성되는 데이터베이스 이름
  master_username           = var.master_username
  master_password           = var.master_password
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora_cluster_parameter_group.id
  db_instance_parameter_group_name = aws_db_parameter_group.aurora_db_parameter_group.id
  backup_retention_period   = var.backup_retention_period   # 백업보존기간
  preferred_backup_window   = var.preferred_backup_window   # 백업이 발생되는 일일 시간 범위
  storage_encrypted         = true            # DB클러스터 암호화 여부 지정 (KMS지정할때는 true)
  kms_key_id                = var.kms_key_arn # KMS 암호화 키의 ARN
  apply_immediately         = false           # 클러스터 수정 사항의 즉시반영 (false이면 정비지정시간에 반영)
  vpc_security_group_ids    = [aws_security_group.rds.0.id]
  skip_final_snapshot       = true            # DB클러스터 삭제시 스냅샷 생성 여부
  final_snapshot_identifier = null            # skip_final_snapshot가 true이면 null
  snapshot_identifier       = ""              # DB 클러스터가 삭제될 때 최종 DB 스냅샷의 이름
  enabled_cloudwatch_logs_exports = ["postgresql"]  # 클라우드 워치로 보낼 로그유형집합

  tags = {
    Name = format("%s-%s-%s", var.svr_nm, var.env, "aurora-db")
  }
  lifecycle {
    ignore_changes = [
      replication_source_identifier
    ]
  }
}

###################################################################################
# Amazon EC2 서비스 생성 :: RDS Instance
###################################################################################
resource "aws_rds_cluster_instance" "primary" {
  for_each = var.instances.class_name

  identifier                   = format("%s-%s-%s", var.svr_nm, var.env, "${each.value}")
  cluster_identifier           = aws_rds_cluster.rds.cluster_identifier
  engine                       = aws_rds_cluster.rds.engine
  engine_version               = aws_rds_cluster.rds.engine_version
  auto_minor_version_upgrade   = true
  instance_class               = format("%s-%s-%s", var.svr_nm, var.env, "${each.key}")
  db_subnet_group_name         = aws_db_subnet_group.rds.name
  db_parameter_group_name      = aws_db_parameter_group.aurora_db_parameter_group.id
  performance_insights_enabled = true
  monitoring_interval          = 30
  monitoring_role_arn          = aws_iam_role.rds_enhanced_monitoring.arn
  apply_immediately            = true
  tags                         = {
    Name = format("%s-%s-%s", var.svr_nm, var.env, "${each.value}")
  }
}
