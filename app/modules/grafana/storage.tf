###########################################################################
# Local Variables
###########################################################################
locals {
  s3_bucket_name = format("%s-%s-%s", "monitor", var.svr_nm, var.env)
  sse_algorithm = var.kms_key_arn == null ? "AES256" : "aws:kms"
}

###########################################################################
# VPC FlowLog KMS KEY - Alias
###########################################################################
resource "aws_kms_alias" "this" {
  name = format("%s/%s", "alias", local.s3_bucket_name)
  target_key_id = var.kms_key_arn
}

###########################################################################
# Loki Storage용 S3 버킷 생성
###########################################################################
resource "aws_s3_bucket" "this" {
  bucket = local.s3_bucket_name
  force_destroy = var.s3_force_destroy
}

# s3 저장소 acl
resource "aws_s3_bucket_acl" "storage" {
    bucket = aws_s3_bucket.this.id
    acl = "private"
}

# s3 서버측 암호화 활성화
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm = local.sse_algorithm
    }
  }
}

# s3 저장소 lifecycle 설정
resource "aws_s3_bucket_lifecycle_configuration" "storage" {
  bucket = aws_s3_bucket.this.id

  rule {
    id = "expire"
    status = "Enabled"
    
    filter {
      prefix = "expire/"
    }

    transition {
      days = 90
      storage_class = "GLACIER_IR"
    }

    transition {
      days = 180
      storage_class = "DEEP_ARCHIVE"
    }

    expiration {
      days = var.expiration_days
    }
  }
}

###########################################################################
# S3 버킷 access block 지정
###########################################################################
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

###########################################################################
# DynamoDB 테이블 생성 :: Loki에서 자동생성하므로, 필요없음
###########################################################################
# resource "aws_dynamodb_table" "loki" {
#   hash_key = "h"
#   range_key = "r"
#   name = "loki-distributed"
#   read_capacity  = 1
#   write_capacity = 1
# 
#   attribute {
#     name = "h"
#     type = "S"
#   }
#   attribute {
#     name = "r"
#     type = "B"
#   }
#   server_side_encryption {
#     enabled = true
#     kms_key_arn = var.kms_key_arn
#   }
# }
