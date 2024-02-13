resource "confluent_api_key" "env-manager-schema-registry-api-key" {
  display_name = "env-manager-schema-registry-api-key"
  description  = "Schema Registry API Key that is owned by 'env-manager' service account"
  owner {
    id          = confluent_service_account.schema_registry_sa.id
    api_version = confluent_service_account.schema_registry_sa.api_version
    kind        = confluent_service_account.schema_registry_sa.kind
  }

  managed_resource {
    id          = confluent_schema_registry_cluster.essentials.id
    api_version = confluent_schema_registry_cluster.essentials.api_version
    kind        = confluent_schema_registry_cluster.essentials.kind

    environment {
      id = confluent_environment.cc_env.id
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

data "confluent_schema_registry_region" "registry_cloud" {
  cloud   = var.cloud_provider
  region  = var.cloud_region
  package = "ESSENTIALS"
}

resource "confluent_schema_registry_cluster" "essentials" {
  package = data.confluent_schema_registry_region.registry_cloud.package

  environment {
    id = confluent_environment.cc_env.id
  }

  region {
    # See https://docs.confluent.io/cloud/current/stream-governance/packages.html#stream-governance-regions
    # Schema Registry and Kafka clusters can be in different regions as well as different cloud providers,
    # but you should to place both in the same cloud and region to restrict the fault isolation boundary.
    id = data.confluent_schema_registry_region.registry_cloud.id
  }

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [
    confluent_kafka_cluster.basic
  ]
}