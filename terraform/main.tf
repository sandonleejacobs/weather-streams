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

# Option #1: Manage multiple clusters in the same Terraform workspace
provider "confluent" {
#  cloud_api_key    = var.confluent_cloud_api_key    # optionally use CONFLUENT_CLOUD_API_KEY env var
#  cloud_api_secret = var.confluent_cloud_api_secret # optionally use CONFLUENT_CLOUD_API_SECRET env var
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

#data "confluent_schema_registry_region" "registry_cloud" {
#  cloud   = var.cloud_provider
#  region  = var.cloud_region
#  package = "ESSENTIALS"
#}
#
#resource "confluent_schema_registry_cluster" "essentials" {
#  package = data.confluent_schema_registry_region.registry_cloud.package
#
#  environment {
#    id = confluent_environment.cc_env.id
#  }
#
#  region {
#    # See https://docs.confluent.io/cloud/current/stream-governance/packages.html#stream-governance-regions
#    # Schema Registry and Kafka clusters can be in different regions as well as different cloud providers,
#    # but you should to place both in the same cloud and region to restrict the fault isolation boundary.
#    id = data.confluent_schema_registry_region.registry_cloud.id
#  }
#
#  lifecycle {
#     prevent_destroy = true
#  }
#}