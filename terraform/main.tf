# Configure the Confluent Provider
terraform {
  backend "local" {
    workspace_dir = ".tfstate/terraform.state"
  }

  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "1.60.0"
    }
  }
}

provider "confluent" {
#  cloud_api_key    = var.confluent_cloud_api_key    # optionally use CONFLUENT_CLOUD_API_KEY env var
#  cloud_api_secret = var.confluent_cloud_api_secret # optionally use CONFLUENT_CLOUD_API_SECRET env var
}

resource "confluent_service_account" "weather-streams-kafka-sa" {
  display_name = "weather-streams-kafka-sa"
  description  = "Service Account for kafka"
}

resource "confluent_role_binding" "weather-streams-kafka-cluster-admin" {
  principal   = "User:${confluent_service_account.weather-streams-kafka-sa.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.basic.rbac_crn

  depends_on = [
    confluent_service_account.weather-streams-kafka-sa
  ]
}

resource "confluent_service_account" "weather-streams-sr-sa" {
  display_name = "weather-streams-sr-sa"
  description  = "Service Account for schema-registry"
}

resource "confluent_environment" "cc_env" {
  display_name = var.cc_env_display_name

  lifecycle {
    prevent_destroy = false
  }
}

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

resource "confluent_api_key" "app-manager-kafka-api-key" {
  display_name = "app-manager-kafka-api-key"
  description  = "Kafka API Key that is owned by '${confluent_service_account.weather-streams-kafka-sa.display_name}' service account"
  owner {
    id          = confluent_service_account.weather-streams-kafka-sa.id
    api_version = confluent_service_account.weather-streams-kafka-sa.api_version
    kind        = confluent_service_account.weather-streams-kafka-sa.kind
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
    confluent_role_binding.weather-streams-kafka-cluster-admin,
    confluent_service_account.weather-streams-kafka-sa
  ]
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

resource "confluent_api_key" "env-manager-sr-api-key" {
  display_name = "app-manager-kafka-api-key"
  description  = "Schema Registry API Key that is owned by '${confluent_service_account.weather-streams-sr-sa.display_name}' service account"
  owner {
    id          = confluent_service_account.weather-streams-sr-sa.id
    api_version = confluent_service_account.weather-streams-sr-sa.api_version
    kind        = confluent_service_account.weather-streams-sr-sa.kind
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
    prevent_destroy = false
  }
}
