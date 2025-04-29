variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = bool
}
variable "client_config" {}
variable "diagnostics" {}
variable "diagnostic_profiles" {}
variable "combined_diagnostics" {}
variable "combined_resources" {
  description = "Provide a map of combined resources for environment_variables_from_resources"
  default     = {}
}
variable "global_settings" {}
variable "location" {}
variable "resource_group_name" {}
variable "resource_group" {
  description = "Resource group object to deploy the virtual machine"
}
variable "settings" {}
variable "container_app_environment_id" {}
variable "replica_timeout_in_seconds" {
  default = 600
}
variable "workload_profile_name" {
  default = "Consumption"
}
variable "replica_retry_limit" {
  default = 5
}
variable "manual_trigger_config" {
  default = {}
}