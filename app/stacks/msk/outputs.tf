###############################################################
# Amazon MSK 보안그룹 ID
###############################################################
output "msk_security_group" {
  value = module.msk.msk_security_group
}

###############################################################
# Amazon MSK ARN
###############################################################
output "msk_arn" {
  value = module.msk.msk_arn
}

###############################################################
# Amazon MSK :: Bootstrap Brokers
###############################################################
output "bootstrap_brokers" {
  value = module.msk.bootstrap_brokers
}

###############################################################
# Amazon MSK :: Bootstrap Brokers TLS
###############################################################
output "bootstrap_brokers_tls" {
  value = module.msk.bootstrap_brokers_tls
}

###############################################################
# Amazon MSK :: Current Version
###############################################################
output "msk_current_version" {
  value = module.msk.msk_current_version
}

###############################################################
# Amazon MSK :: KMS ARN
###############################################################
output "encryption_at_rest_kms_key_arn" {
  value = module.msk.encryption_at_rest_kms_key_arn
}

###############################################################
# Amazon MSK :: Zookeeper Connect String
###############################################################
output "zookeeper_connect_string" {
  value = module.msk.zookeeper_connect_string
}