#// inbound zone definitions
#resource "confluent_kafka_topic" "noaa_zones_inbound" {
#  kafka_cluster {
#    id = confluent_kafka_cluster.basic.id
#  }
#
#  topic_name       = "noaa-zones-inbound"
#  partitions_count = 1
#  config = {
#    "cleanup.policy" = "delete"
#  }
#  lifecycle {
#    prevent_destroy = var.cc_prevent_destroy
#  }
#}
#
#// inbound active alerts
#resource "confluent_kafka_topic" "noaa_alerts_active_inbound" {
#  kafka_cluster {
#    id = confluent_kafka_cluster.basic.id
#  }
#
#  topic_name       = "noaa-alerts-active-inbound"
#  partitions_count = 3
#  config = {
#    "cleanup.policy" = "delete"
#  }
#  lifecycle {
#    prevent_destroy = var.cc_prevent_destroy
#  }
#}
