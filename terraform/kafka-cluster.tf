resource "confluent_kafka_cluster" "basic" {
  display_name = var.cc_cluster_name
  availability = "SINGLE_ZONE"
  cloud        = var.cloud_provider
  region       = var.cloud_region
  basic {}

  environment {
    id = confluent_environment.cc_env.id
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "confluent_role_binding" "cluster_admin_rb" {
  principal   = "User:${confluent_service_account.kafka_admin_sa.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.basic.rbac_crn
}

resource "confluent_api_key" "kafka_api_key" {
  display_name = "kafka-api-key"
  description  = "Kafka API Key that is owned by '${confluent_service_account.kafka_admin_sa.display_name}' service account"
  owner {
    id          = confluent_service_account.kafka_admin_sa.id
    api_version = confluent_service_account.kafka_admin_sa.api_version
    kind        = confluent_service_account.kafka_admin_sa.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.basic.id
    api_version = confluent_kafka_cluster.basic.api_version
    kind        = confluent_kafka_cluster.basic.kind

    environment {
      id = confluent_environment.cc_env.id
    }
  }

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [
    confluent_kafka_cluster.basic,
    confluent_role_binding.cluster_admin_rb,
    confluent_service_account.kafka_admin_sa
  ]
}
