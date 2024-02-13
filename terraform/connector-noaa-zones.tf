#resource "confluent_connector" "noaa_zones_source" {
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
#    "name"                     = "http_src_noaa_zones"
#    "kafka.auth.mode"          = "KAFKA_API_KEY"
#    "kafka.api.key"            = confluent_api_key.env_mgr_kafka_api_key.id
#    "kafka.api.secret"         = confluent_api_key.env_mgr_kafka_api_key.secret
#    "kafka.topic"              = confluent_kafka_topic.noaa_zones_inbound.topic_name
#    "output.data.format"       = "AVRO"
#    "tasks.max"                = "1"
#    "topic.name.pattern"       = confluent_kafka_topic.noaa_zones_inbound.topic_name
#    "url"                      = "https://api.weather.gov/zones"
#    "http.request.parameters"  = "type=land"
#    "http.offset.mode"         = "SIMPLE_INCREMENTING"
#    "http.initial.offset"      = "0"
#    "http.response.data.json.pointer" = "/features"
#    "request.interval.ms"      = 60000
#
#    "transforms"                            = "DropUnusedFields,Flatten,RenameFields,MakeEventKey"
#    "transforms.DropUnusedFields.type"      = "org.apache.kafka.connect.transforms.ReplaceField$Value"
#    "transforms.DropUnusedFields.exclude"   = "id,type"
#
#    "transforms.Flatten.type"               = "org.apache.kafka.connect.transforms.Flatten$Value"
#    "transforms.Flatten.delimiter"          = "_"
#
#    "transforms.RenameFields.type"          = "org.apache.kafka.connect.transforms.ReplaceField$Value"
#    "transforms.RenameFields.renames"       = "properties_@id:url,properties_@type:wxObjectType,properties_id:id,properties_type:zoneType,properties_name:name,properties_effectiveDate:effectiveDate,properties_expirationDate:expirationDate,properties_state:state,properties_cwa:cwas,properties_forecastOffices:forecastOffices,properties_timeZone:timeZones,properties_observationStations:observationStations,properties_radarStation:radarStation"
#
#    "transforms.MakeEventKey.type"          = "org.apache.kafka.connect.transforms.ValueToKey"
#    "transforms.MakeEventKey.fields"        = "id"
#  }
#
#  depends_on = [
#    confluent_kafka_topic.noaa_zones_inbound
#  ]
#
#  lifecycle {
#    prevent_destroy = false
#  }
#}