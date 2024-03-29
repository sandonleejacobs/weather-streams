resource "confluent_flink_statement" "create_ws_zones" {
  organization {
    id = data.confluent_organization.main.id
  }
  environment {
    id = confluent_environment.cc_env.id
  }
  compute_pool {
    id = confluent_flink_compute_pool.weather_compute_pool_1.id
  }
  principal {
    id = confluent_service_account.statements-runner.id
  }
  statement     = file("../flinksql/src/main/sql/create/00__create_ws_zones.sql")
  properties = {
    "sql.current-catalog"  = confluent_environment.cc_env.display_name
    "sql.current-database" = confluent_kafka_cluster.basic.display_name
  }
  rest_endpoint = data.confluent_flink_region.main.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-flink-api-key.id
    secret = confluent_api_key.app-manager-flink-api-key.secret
  }

  depends_on = [
    confluent_flink_compute_pool.weather_compute_pool_1,
    confluent_kafka_topic.noaa_zones_inbound,
    confluent_connector.noaa_zones_source
  ]

  lifecycle {
    prevent_destroy = false
  }
}

resource "confluent_flink_statement" "load_ws_zones" {
  organization {
    id = data.confluent_organization.main.id
  }
  environment {
    id = confluent_environment.cc_env.id
  }
  compute_pool {
    id = confluent_flink_compute_pool.weather_compute_pool_1.id
  }
  principal {
    id = confluent_service_account.statements-runner.id
  }
  statement     = file("../flinksql/src/main/sql/load/00__load_ws_zones.sql")
  properties = {
    "sql.current-catalog"  = confluent_environment.cc_env.display_name
    "sql.current-database" = confluent_kafka_cluster.basic.display_name
  }
  rest_endpoint = data.confluent_flink_region.main.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-flink-api-key.id
    secret = confluent_api_key.app-manager-flink-api-key.secret
  }

  depends_on = [
    confluent_flink_statement.create_ws_zones
  ]

  lifecycle {
    prevent_destroy = false
  }
}
