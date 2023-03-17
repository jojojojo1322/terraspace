##############################################################################
# Local Variables
##############################################################################
locals {
  server_properties = join("\n", [for k, v in var.server_properties : format("%s = %s", k, v)])
  enable_logs = var.s3_logs_bucket != "" || var.cloudwatch_logs_group != "" || var.firehose_logs_delivery_stream != "" ? ["true"] : []
}

##############################################################################
# Amazon MSK Cluster Configuration
##############################################################################
resource "random_id" "configuration" {
  prefix = "${var.svr_nm}-${var.env}-"
  byte_length = 8

  keepers = {
    server_properties = local.server_properties
    kafka_version = var.kafka_version
  }
}

resource "aws_msk_configuration" "this" {
  kafka_versions = [random_id.configuration.keepers.kafka_version]
  name = random_id.configuration.dec
  server_properties = random_id.configuration.keepers.server_properties

  lifecycle {
    create_before_destroy = true
  }
}

###################################################################################
# CloudWatch 생성 :: 브로커 로그 전송
###################################################################################
resource "aws_cloudwatch_log_group" "this" {
  count = var.cloudwatch_logs_group != "" ? 1 : 0

  name = var.cloudwatch_logs_group
  retention_in_days = 7
  kms_key_id = var.kms_key_arn

  tags = {
    name = var.cloudwatch_logs_group
    Environment = var.env
  }
}

##############################################################################
# Amazon MSK Cluster 생성
##############################################################################
resource "aws_msk_cluster" "this" {
  depends_on = [aws_msk_configuration.this]
  count = var.create ? 1 : 0

  cluster_name = format("%s-%s", var.svr_nm, var.env)
  kafka_version = var.kafka_version
  number_of_broker_nodes = length(var.kafka_subnet_ids)
  enhanced_monitoring = var.enhanced_monitoring

  broker_node_group_info {
    client_subnets  = var.kafka_subnet_ids
    instance_type   = var.instance_type
    storage_info {
      ebs_storage_info {
        volume_size = var.ebs_volume_size
      }
    }
    security_groups = concat(aws_security_group.this.*.id, [data.aws_security_group.default.id])
  }

  client_authentication {
    unauthenticated = var.client_authentication_unauthenticated_enabled
    sasl {
      iam   = var.client_authentication_sasl_iam_enabled
      scram = length(aws_secretsmanager_secret.this.arn) == 0 ? false : true
    }
    dynamic "tls" {
      for_each = length(var.client_authentication_tls_certificate_authority_arns) != 0 ? ["true"] : []
      content {
        certificate_authority_arns = var.client_authentication_tls_certificate_authority_arns
      }
    }
  }

  # 클러스터 구성 (MSK기본구성, 사용자지정구성)
  configuration_info {
    arn = aws_msk_configuration.this.arn
    revision = aws_msk_configuration.this.latest_revision
  }

  # 저장된 데이터 암호화 (KMS)
  encryption_info {
    encryption_at_rest_kms_key_arn = var.kms_key_arn
    encryption_in_transit {
      client_broker = var.encryption_in_transit_client_broker
      in_cluster    = var.encryption_in_transit_in_cluster
    }
  }

  # 프로메테우스 오픈모니터링
  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = var.prometheus_jmx_exporter
      }
      node_exporter {
        enabled_in_broker = var.prometheus_node_exporter
      }
    }
  }

  # 브로커 로그 전송
  dynamic "logging_info" {
    for_each = local.enable_logs
    content {
      broker_logs {
        dynamic "firehose" {
          for_each = var.firehose_logs_delivery_stream != "" ? ["true"] : []
          content {
            enabled = true
            delivery_stream = var.firehose_logs_delivery_stream
          }
        }
        dynamic "cloudwatch_logs" {
          for_each = var.cloudwatch_logs_group != "" ? ["true"] : []
          content {
            enabled   = true
            log_group = var.cloudwatch_logs_group
          }
        }
        dynamic "s3" {
          for_each = var.s3_logs_bucket != "" ? ["true"] : []
          content {
            enabled = true
            bucket  = var.s3_logs_bucket
            prefix  = var.s3_logs_prefix
          }
        }
      }
    }
  }

  # 시간이 오래 걸려 타임아웃은 1시간으로 설정. 적정한 시간을 찾아야 됨.
  timeouts {
    create = "40m"
    delete = "30m"
    update = "30m"
  }

  # required for appautoscaling
  lifecycle {
    ignore_changes = [broker_node_group_info[0].ebs_volume_size]
  }

  tags = {
    Owner = "user"
    Environment = var.env
  }
}

##############################################################################
# Amazon MSK Cluster 와 SCRAM Secret 연결
##############################################################################
resource "aws_msk_scram_secret_association" "this" {
  depends_on = [aws_secretsmanager_secret.this]

  cluster_arn = aws_msk_cluster.this.0.arn
  secret_arn_list = [aws_secretsmanager_secret.this.arn]
}
