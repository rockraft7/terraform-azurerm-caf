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
variable "trigger_type" {
  description = "Type of the trigger: manual, event, or schedule"
  type        = string
  validation {
    condition     = contains(["manual", "event", "schedule"], var.trigger_type)
    error_message = "trigger_type must be one of: manual, event, schedule."
  }
}
variable "trigger_config" {
  description = "Trigger configuration for the selected trigger_type"
  type = object({
    parallelism              = optional(number)
    replica_completion_count = optional(number)
    scale = optional(object({
      max_executions              = optional(number)
      min_executions              = optional(number)
      polling_interval_in_seconds = optional(number)
      # Add more nested fields as needed
    }))
    cron_expression = optional(string)
  })
  default = {}
}
