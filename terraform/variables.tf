#variable "confluent_cloud_api_key" {
#  type = string
#}
#
#variable "confluent_cloud_api_secret" {
#  type = string
#}

variable "cloud_provider" {
  type = string
  description = "cloud provider for Confluent Cloud"
  default = "AWS"
}

variable "cloud_region" {
  type = string
  description = "cloud provider region"
  default = "us-east-2"
}

variable "cc_prevent_destroy" {
  type = bool
  description = "protect from tf destroy command"
  default = true
}

variable "cc_env_display_name" {
  type = string
  description = "Name of Confluent Cloud Environment to Manage"
  default = "weather-streams"
}

variable "cc_cluster_name" {
  type = string
  description = "name of kafka cluster"
  default = "weather-cluster-1"
}


variable "org_id" {
  type = string
  default = "2929cae7-840e-47d3-b6f5-67d03587cd01"
}

