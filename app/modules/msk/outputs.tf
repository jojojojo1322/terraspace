output "msk_security_group" {
  description = "Msk cluster default security group id."
  value       = aws_security_group.this.0.id
}

output "msk_arn" {
  description = "Amazon Resource Name (ARN) of the MSK cluster."
  value = aws_msk_cluster.this.0.arn
}

output "bootstrap_brokers" {
  description = " A comma separated list of one or more hostname:port pairs of kafka brokers suitable to boostrap connectivity to the kafka cluster. Only contains value if client_broker encryption in transit is set o PLAINTEXT or TLS_PLAINTEXT."
  value = aws_msk_cluster.this.0.bootstrap_brokers
}

output "bootstrap_brokers_tls" {
  description = "A comma separated list of one or more DNS names (or IPs) and TLS port pairs kafka brokers suitable to boostrap connectivity to the kafka cluster. Only contains value if client_broker encryption in transit is set to TLS_PLAINTEXT or TLS."
  value = aws_msk_cluster.this.0.bootstrap_brokers_tls
}

output "msk_current_version" {
  description = "Current version of the MSK Cluster used for updates, e.g. K13V1IB3VIYZZH"
  value = aws_msk_cluster.this.0.current_version
}

output "encryption_at_rest_kms_key_arn" {
  description = "The ARN of the KMS key used for encryption at rest of the broker data volumes."
  value = aws_msk_cluster.this.0.encryption_info.0.encryption_at_rest_kms_key_arn
}

output "zookeeper_connect_string" {
  description = "A comma separated list of one or more hostname:port pairs to use to connect to the Apache Zookeeper cluster."
  value = aws_msk_cluster.this.0.zookeeper_connect_string
}