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
}

resource "confluent_service_account" "kafka_admin_sa" {
  display_name = "weather-streams-kafka-admin-sa"
  description  = "Service Account for kafka"

  lifecycle {
    prevent_destroy = false
  }
}

resource "confluent_service_account" "schema_registry_sa" {
  display_name = "weather-streams-schema-registry-sa"
  description  = "Service Account for Schema Registry"
}

resource "confluent_environment" "cc_env" {
  display_name = var.cc_env_display_name

  lifecycle {
    prevent_destroy = false
  }
}

