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
#    prevent_destroy = false
#  }
#
#  depends_on = [
#    confluent_kafka_cluster.basic
#  ]
#}
#
#resource "confluent_schema_registry_cluster_config" "sr_essentials_config" {
#  schema_registry_cluster {
#    id = confluent_schema_registry_cluster.essentials.id
#  }
#  rest_endpoint       = confluent_schema_registry_cluster.essentials.rest_endpoint
#  compatibility_level = "FULL"
#  credentials {
#    key    = confluent_api_key.kafka_api_key.id
#    secret = confluent_api_key.kafka_api_key.secret
#  }
#
#  lifecycle {
#    prevent_destroy = false
#  }
#}
#
#resource "confluent_schema_registry_cluster_mode" "sr_cluster_mode" {
#  schema_registry_cluster {
#    id = confluent_schema_registry_cluster.essentials.id
#  }
#  rest_endpoint = confluent_schema_registry_cluster.essentials.rest_endpoint
#  mode          = "READWRITE"
#  credentials {
#    key    = confluent_api_key.kafka_api_key.id
#    secret = confluent_api_key.kafka_api_key.secret
#  }
#
#  lifecycle {
#    prevent_destroy = false
#  }
#}
#
#resource "confluent_role_binding" "sr_resource_owner_rb" {
#  principal   = "User:${confluent_service_account.schema_registry_sa.id}"
#  role_name   = "ResourceOwner"
#  crn_pattern = "${confluent_schema_registry_cluster.essentials.resource_name}/subject=*"
##
##  crn_pattern = confluent_schema_registry_cluster.essentials.resource_name
#
#  depends_on = [
#    confluent_schema_registry_cluster.essentials
#  ]
#}
#
#resource "confluent_api_key" "env_mgr_sr_api_key" {
#  display_name = "env-manager-schema-registry-api-key"
#  description  = "Schema Registry API Key that is owned by 'env-manager' service account"
#  owner {
#    id          = confluent_service_account.schema_registry_sa.id
#    api_version = confluent_service_account.schema_registry_sa.api_version
#    kind        = confluent_service_account.schema_registry_sa.kind
#  }
#
#  managed_resource {
#    id          = confluent_schema_registry_cluster.essentials.id
#    api_version = confluent_schema_registry_cluster.essentials.api_version
#    kind        = confluent_schema_registry_cluster.essentials.kind
#
#    environment {
#      id = confluent_environment.cc_env.id
#    }
#  }
#
#  lifecycle {
#    prevent_destroy = true
#  }
#}