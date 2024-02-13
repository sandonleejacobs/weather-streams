#resource "confluent_schema" "noaa_alerts_active_inbound_value" {
#
#  schema_registry_cluster {
#    id = confluent_schema_registry_cluster.essentials.id
#  }
#  rest_endpoint = confluent_schema_registry_cluster.essentials.rest_endpoint
#
#  credentials {
#    key    = confluent_api_key.env_mgr_kafka_api_key.id
#    secret = confluent_api_key.env_mgr_kafka_api_key.secret
#  }
#
#  format       = "AVRO"
#  subject_name = "${confluent_kafka_topic.noaa_alerts_active_inbound.topic_name}-value"
#
#  schema = file("../data/src/main/avro/NoaaAlertsActive-value.avsc")
#
#  lifecycle {
#    prevent_destroy = false
#  }
#
#  depends_on = [
#    confluent_schema_registry_cluster.essentials,
#    confluent_api_key.env_mgr_kafka_api_key
#  ]
#}
#
#resource "confluent_subject_config" "noaa_alerts_active_inbound_value_cfg" {
#  schema_registry_cluster {
#    id = confluent_schema_registry_cluster.essentials.id
#  }
#  rest_endpoint       = confluent_schema_registry_cluster.essentials.rest_endpoint
#  subject_name        = "${confluent_kafka_topic.noaa_alerts_active_inbound.topic_name}-value"
#  compatibility_level = "NONE"
#
#  credentials {
#    key    = confluent_api_key.env_mgr_kafka_api_key.id
#    secret = confluent_api_key.env_mgr_kafka_api_key.secret
#  }
#
#  lifecycle {
#    prevent_destroy = true
#  }
#
#  depends_on = [
#    confluent_schema.noaa_alerts_active_inbound_value,
#    confluent_schema_registry_cluster.essentials,
#    confluent_api_key.env_mgr_kafka_api_key
#  ]
#}
