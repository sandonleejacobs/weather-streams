resource "confluent_flink_statement" "create_alert_zone_state" {
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
  statement     = file("../flinksql/src/main/sql/create/03__create_alert_zone_state.sql")
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
    confluent_flink_statement.create_active_alerts_zone_expanded
  ]

  lifecycle {
    prevent_destroy = false
  }
}

resource "confluent_flink_statement" "load_alert_zone_state" {
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
  statement     = file("../flinksql/src/main/sql/load/03__load_alert_zone_state.sql")
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
    confluent_flink_statement.create_alert_zone_state
  ]

  lifecycle {
    prevent_destroy = false
  }
}