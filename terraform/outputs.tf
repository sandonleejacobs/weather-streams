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

output "flink_weather_compute_pool_1_id" {
  value = confluent_flink_compute_pool.weather_compute_pool_1.id
}

output "flink_weather_compute_pool_1_display_name" {
  value = confluent_flink_compute_pool.weather_compute_pool_1.display_name
}

output "flink_weather_compute_pool_1_rest_endpoint" {
  value = confluent_flink_compute_pool.weather_compute_pool_1.rest_endpoint
}

output "flink_weather_compute_pool_1_resource_name" {
  value = confluent_flink_compute_pool.weather_compute_pool_1.resource_name
}

output "topic_name_noa_zones_in" {
  value =  confluent_kafka_topic.noaa_zones_inbound.topic_name
}

output "topic_name_noa_active_alerts_id" {
  value =  confluent_kafka_topic.noaa_alerts_active_inbound.topic_name
}
#
#output "connector_noaa_zones_source" {
#  value = confluent_connector.noaa_zones_source.id
#}
