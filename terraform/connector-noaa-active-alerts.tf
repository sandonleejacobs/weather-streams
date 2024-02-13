#resource "confluent_connector" "noaa_alerts_source" {
#  environment {
#    id = confluent_environment.cc_env.id
#  }
#  kafka_cluster {
#    id = confluent_kafka_cluster.basic.id
#  }
#
#  config_sensitive = {}
#
#  config_nonsensitive = {
#    "connector.class"          = "HttpSource"
#    "name"                     = "http_src_noaa_alerts"
#    "kafka.auth.mode"          = "KAFKA_API_KEY"
#    "kafka.api.key"            = confluent_api_key.app_manager_kafka_api_key.id
#    "kafka.api.secret"         = confluent_api_key.app_manager_kafka_api_key.secret
#    "kafka.topic"              = confluent_kafka_topic.noaa_alerts_active_inbound.topic_name
#    "output.data.format"       = "AVRO"
#    "tasks.max"                = "1"
#    "topic.name.pattern"       = confluent_kafka_topic.noaa_alerts_active_inbound.topic_name
#    "url"                      = "https://api.weather.gov/alerts/active"
#    "http.request.parameters"  = "status=actual&limit=10"
#    "http.offset.mode"         = "SIMPLE_INCREMENTING"
#    "http.initial.offset"      = "0"
#    "http.response.data.json.pointer" = "/features"
#    "request.interval.ms"      = 60000
#
#    "transforms"                            = "MakeEventKey"
#    "transforms.MakeEventKey.type"          = "org.apache.kafka.connect.transforms.ValueToKey"
#    "transforms.MakeEventKey.fields"        = "id"
#  }
#
#  depends_on = [
#    confluent_kafka_topic.noaa_alerts_active_inbound,
#    confluent_subject_config.noaa_alerts_active_inbound_value_cfg
#  ]
#
#  lifecycle {
#    prevent_destroy = false
#  }
#}