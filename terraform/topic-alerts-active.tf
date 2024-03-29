# inbound active alerts
resource "confluent_kafka_topic" "noaa_alerts_active_inbound" {
  kafka_cluster {
    id = confluent_kafka_cluster.basic.id
  }

  topic_name       = "NoaaAlertsActiveInbound"
  rest_endpoint      = confluent_kafka_cluster.basic.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }

  partitions_count = 3
  config = {
    "cleanup.policy" = "delete"
    "retention.ms" = 300000
  }
  lifecycle {
    prevent_destroy = false
  }

  depends_on = [
    confluent_schema_registry_cluster.essentials
  ]
}

resource "confluent_schema" "noaa_alerts_active_inbound_value" {

  schema_registry_cluster {
    id = confluent_schema_registry_cluster.essentials.id
  }
  rest_endpoint = confluent_schema_registry_cluster.essentials.rest_endpoint

  credentials {
    key    = confluent_api_key.env-manager-schema-registry-api-key.id
    secret = confluent_api_key.env-manager-schema-registry-api-key.secret
  }

  format       = "AVRO"
  subject_name = "${confluent_kafka_topic.noaa_alerts_active_inbound.topic_name}-value"

  schema = file("../data/src/main/avro/NoaaAlertsActiveInbound-value.avsc")

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [
    confluent_kafka_topic.noaa_alerts_active_inbound
  ]
}

resource "confluent_subject_config" "noaa_alerts_active_inbound_value_cfg" {
  schema_registry_cluster {
    id = confluent_schema_registry_cluster.essentials.id
  }
  rest_endpoint       = confluent_schema_registry_cluster.essentials.rest_endpoint
  subject_name        = "${confluent_kafka_topic.noaa_alerts_active_inbound.topic_name}-value"
  compatibility_level = "NONE"

  credentials {
    key    = confluent_api_key.env-manager-schema-registry-api-key.id
    secret = confluent_api_key.env-manager-schema-registry-api-key.secret
  }

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [
    confluent_schema.noaa_alerts_active_inbound_value
  ]
}

