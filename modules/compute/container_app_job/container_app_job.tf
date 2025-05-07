resource "azurecaf_name" "caj" {
  name          = var.settings.name
  prefixes      = var.global_settings.prefixes
  resource_type = "general"
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

resource "azurerm_container_app_job" "caj" {
  name                         = azurecaf_name.caj.result
  resource_group_name          = local.resource_group_name
  container_app_environment_id = var.container_app_environment_id
  tags                         = merge(local.tags, try(var.settings.tags, null))
  location                     = local.location
  replica_timeout_in_seconds   = var.replica_timeout_in_seconds
  workload_profile_name        = var.workload_profile_name
  replica_retry_limit          = var.replica_retry_limit

  dynamic "manual_trigger_config" {
    for_each = var.trigger_type == "manual" ? var.trigger_config : []
    content {
      parallelism              = try(manual_trigger_config.value.parallelism, 1)
      replica_completion_count = try(manual_trigger_config.value.replica_completion_count, 1)
    }
  }

  dynamic "event_trigger_config" {
    for_each = var.trigger_type == "event" ? var.trigger_config : []
    content {
      parallelism              = try(event_trigger_config.value.parallelism, 1)
      replica_completion_count = try(event_trigger_config.value.replica_completion_count, 1)
      # dynamic "scale" {
      #   for_each = try(event_trigger_config.value.scale, {})
        
      #   content {
      #     max_executions              = try(scale.value.max_executions, null)
      #     min_executions              = try(scale,value.min_executions, null)
      #     polling_interval_in_seconds = try(scale.value.polling_interval_in_seconds, null)
      #     # rules
      #   }
      # }
    }
  }

  dynamic "schedule_trigger_config" {
    for_each = var.trigger_type == "schedule" ? var.trigger_config : []
    content {
      parallelism              = try(schedule_trigger_config.value.parallelism, 1)
      cron_expression          = try(schedule_trigger_config.value.cron_expression, null)
      replica_completion_count = try(schedule_trigger_config.value.replica_completion_count, 1)
    }
  }

  template {
    dynamic "container" {
      for_each = var.settings.template.container

      content {
        name    = container.value.name
        image   = container.value.image
        args    = try(container.value.args, null)
        command = try(container.value.command, null)
        cpu     = container.value.cpu
        memory  = container.value.memory

        dynamic "env" {
          for_each = try(container.value.env, {})

          content {
            name        = env.value.name
            secret_name = try(env.value.secret_name, null)
            value       = try(env.value.value, null)
          }
        }

        dynamic "liveness_probe" {
          for_each = can(container.value.liveness_probe) ? [container.value.liveness_probe] : []

          content {
            failure_count_threshold          = try(liveness_probe.value.failure_count_threshold, null)
            host                             = try(liveness_probe.value.host, null)
            initial_delay                    = try(liveness_probe.value.initial_delay, null)
            interval_seconds                 = try(liveness_probe.value.interval_seconds, null)
            path                             = try(liveness_probe.value.path, null)
            port                             = liveness_probe.value.port
            termination_grace_period_seconds = try(liveness_probe.value.termination_grace_period_seconds, null)
            timeout                          = try(liveness_probe.value.timeout, null)
            transport                        = liveness_probe.value.transport

            dynamic "header" {
              for_each = can(liveness_probe.value.header) ? [liveness_probe.value.header] : []

              content {
                name  = header.value.name
                value = header.value.value
              }
            }
          }
        }

        dynamic "readiness_probe" {
          for_each = can(container.value.readiness_probe) ? [container.value.readiness_probe] : []

          content {
            failure_count_threshold = try(readiness_probe.value.failure_count_threshold, null)
            host                    = try(readiness_probe.value.host, null)
            interval_seconds        = try(readiness_probe.value.interval_seconds, null)
            path                    = try(readiness_probe.value.path, null)
            port                    = readiness_probe.value.port
            success_count_threshold = try(readiness_probe.value.success_count_threshold, null)
            timeout                 = try(readiness_probe.value.timeout, null)
            transport               = readiness_probe.value.transport

            dynamic "header" {
              for_each = can(readiness_probe.value.header) ? [readiness_probe.value.header] : []

              content {
                name  = header.value.name
                value = header.value.value
              }
            }
          }
        }

        dynamic "startup_probe" {
          for_each = can(container.value.startup_probe) ? [container.value.startup_probe] : []

          content {
            failure_count_threshold          = try(startup_probe.value.failure_count_threshold, null)
            host                             = try(startup_probe.value.host, null)
            interval_seconds                 = try(startup_probe.value.interval_seconds, null)
            path                             = try(startup_probe.value.path, null)
            port                             = startup_probe.value.port
            termination_grace_period_seconds = try(startup_probe.value.termination_grace_period_seconds, null)
            timeout                          = try(startup_probe.value.timeout, null)
            transport                        = startup_probe.value.transport

            dynamic "header" {
              for_each = can(startup_probe.value.header) ? [startup_probe.value.header] : []

              content {
                name  = header.value.name
                value = header.value.value
              }
            }
          }
        }

        dynamic "volume_mounts" {
          for_each = try(container.value.volume_mounts, {})

          content {
            name = volume_mounts.value.name
            path = volume_mounts.value.path
          }
        }
      }
    }

    dynamic "init_container" {
      for_each = try(var.settings.template.init_container, {})

      content {
        name    = init_container.value.name
        image   = init_container.value.image
        args    = try(init_container.value.args, null)
        command = try(init_container.value.command, null)
        cpu     = try(init_container.value.cpu, null)
        memory  = try(init_container.value.memory, null)

        dynamic "env" {
          for_each = try(init_container.value.env, {})

          content {
            name        = env.value.name
            secret_name = try(env.value.secret_name, null)
            value       = try(env.value.value, null)
          }
        }

        dynamic "volume_mounts" {
          for_each = try(init_container.value.volume_mounts, {})

          content {
            name = volume_mounts.value.name
            path = volume_mounts.value.path
          }
        }
      }
    }

    dynamic "volume" {
      for_each = try(var.settings.template.volume, {})

      content {
        name         = volume.value.name
        storage_name = try(volume.value.storage_name, null)
        storage_type = try(volume.value.storage_type, null)
      }
    }
  }

  dynamic "secret" {
    for_each = try(var.settings.secret, {})

    content {
      name  = secret.value.name
      value = try(secret.value.value, null)
      identity = can(secret.value.identity.key) ? var.combined_resources.managed_identities[try(secret.value.identity.lz_key, var.client_config.landingzone_key)][secret.value.identity.key].id : try(secret.value.identity.id, null)
      key_vault_secret_id = try(secret.value.key_vault_secret_id, null)
    }
  }

  dynamic "identity" {
    for_each = can(var.settings.identity) ? [var.settings.identity] : []

    content {
      type         = var.settings.identity.type
      identity_ids = local.managed_identities
    }
  }

  dynamic "registry" {
    for_each = can(var.settings.registry) ? [var.settings.registry] : []

    content {
      server               = registry.value.server
      identity             = can(registry.value.identity.key) ? var.combined_resources.managed_identities[try(registry.value.identity.lz_key, var.client_config.landingzone_key)][registry.value.identity.key].id : try(registry.value.identity.id, null)
      username             = try(registry.value.username, null)
      password_secret_name = try(registry.value.password_secret_name, null)
    }
  }
}
