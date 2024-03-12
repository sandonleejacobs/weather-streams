resource "confluent_flink_statement" "create_ws_active_alerts" {
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
  statement     = file("../flinksql/src/main/sql/create-tables/ws_active_alerts.sql")
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
    confluent_api_key.app-manager-flink-api-key
  ]
}

resource "confluent_flink_statement" "insert_into_ws_active_alerts" {
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
  statement     = file("../flinksql/src/main/sql/insert-into/ws_active_alerts.sql")
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
    confluent_flink_statement.create_ws_active_alerts
  ]
}