###############################################################
# KMS KEY
###############################################################
output "kms_key_arn" {
  value = aws_kms_key.eks.arn
}