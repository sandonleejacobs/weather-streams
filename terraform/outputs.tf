output "cc_env_display_name" {
  value = confluent_environment.cc_env.display_name
}

output "cc_env_id" {
  value = confluent_environment.cc_env.id
}

output "cc_kafka_cluster_id" {
  value = confluent_kafka_cluster.basic.id
}

output "cc_kafka_cluster_bootstrap_endpoint" {
  value = confluent_kafka_cluster.basic.bootstrap_endpoint
}

output "cc_kafka_cluster_rest_endpoint" {
  value = confluent_kafka_cluster.basic.rest_endpoint
}

output "cc_schema_registry_id" {
  value = confluent_schema_registry_cluster.essentials.id
}

output "cc_schema_registry_endpoint" {
  value = confluent_schema_registry_cluster.essentials.rest_endpoint
}
