variable "bot_name" {
  description = "Name of the Lex bot"
  type        = string

  validation {
    condition     = length(var.bot_name) > 0 && length(var.bot_name) <= 100
    error_message = "Bot name must be between 1 and 100 characters."
  }
}

variable "bot_description" {
  description = "Description of the Lex bot"
  type        = string
  default     = ""
}

variable "child_directed" {
  description = "Whether the bot is directed at children under 13"
  type        = bool
  default     = false
}

variable "idle_session_ttl_in_seconds" {
  description = "The maximum time in seconds that Amazon Lex retains the data gathered in a conversation"
  type        = number
  default     = 300

  validation {
    condition     = var.idle_session_ttl_in_seconds >= 60 && var.idle_session_ttl_in_seconds <= 86400
    error_message = "Idle session TTL must be between 60 and 86400 seconds."
  }
}

variable "bot_type" {
  description = "Type of the bot (Bot or BotNetwork)"
  type        = string
  default     = "Bot"

  validation {
    condition     = contains(["Bot", "BotNetwork"], var.bot_type)
    error_message = "Bot type must be either 'Bot' or 'BotNetwork'."
  }
}

variable "iam_role_name" {
  description = "Name for the IAM role. If empty, will use bot_name-role"
  type        = string
  default     = ""
}

variable "iam_policy_arns" {
  description = "List of IAM policy ARNs to attach to the Lex bot role"
  type        = list(string)
  default     = []
}

variable "bot_members" {
  description = "List of bot members for BotNetwork type"
  type = list(object({
    alias_id   = string
    alias_name = string
    id         = string
    name       = string
    version    = string
  }))
  default = []
}

variable "bot_locales" {
  description = "List of bot locales to configure"
  type = list(object({
    locale_id                        = string
    bot_version                      = optional(string, "DRAFT")
    n_lu_intent_confidence_threshold = number
    description                      = optional(string, "")
    voice_settings = optional(object({
      voice_id = string
      engine   = optional(string, "standard")
    }), null)
  }))
  default = []

  validation {
    condition = alltrue([
      for locale in var.bot_locales :
      locale.n_lu_intent_confidence_threshold >= 0 && locale.n_lu_intent_confidence_threshold <= 1
    ])
    error_message = "n_lu_intent_confidence_threshold must be between 0 and 1."
  }

  validation {
    condition = alltrue([
      for locale in var.bot_locales :
      locale.voice_settings == null || contains(["standard", "neural"], locale.voice_settings.engine)
    ])
    error_message = "Voice engine must be either 'standard' or 'neural'."
  }
}

variable "locale_timeouts" {
  description = "Timeout configuration for bot locale operations"
  type = object({
    create = optional(string, "30m")
    update = optional(string, "30m")
    delete = optional(string, "30m")
  })
  default = {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "bot_versions" {
  description = "List of bot versions to create"
  type = list(object({
    version_name = string
    description  = optional(string, "")
    locale_specification = map(object({
      source_bot_version = string
    }))
  }))
  default = []
}

variable "bot_intents" {
  description = "List of intents to create for the bot"
  type = list(object({
    name        = string
    bot_version = optional(string, "DRAFT")
    locale_id   = string
    description = optional(string, "")
    sample_utterances = optional(list(string), [])
    parent_intent_signature = optional(string, null)
    
    dialog_code_hook = optional(object({
      enabled = bool
    }), null)
    
    fulfillment_code_hook = optional(object({
      enabled = bool
      active  = optional(bool, true)
      post_fulfillment_status_specification = optional(object({
        success_response = optional(object({
          allow_interrupt = optional(bool, false)
          message_groups = list(object({
            plain_text_message = string
          }))
        }), null)
      }), null)
    }), null)
    
    confirmation_setting = optional(object({
      active = optional(bool, true)
      prompt_specification = object({
        max_retries                = number
        allow_interrupt            = optional(bool, false)
        message_selection_strategy = optional(string, "Ordered")
        message_groups = list(object({
          plain_text_message = string
        }))
        prompt_attempts_specification = optional(list(object({
          allow_interrupt = optional(bool, true)
          map_block_key   = string
          allowed_input_types = object({
            allow_audio_input = bool
            allow_dtmf_input  = bool
          })
          audio_and_dtmf_input_specification = optional(object({
            start_timeout_ms = number
            audio_specification = object({
              end_timeout_ms = number
              max_length_ms  = number
            })
            dtmf_specification = object({
              deletion_character = string
              end_character      = string
              end_timeout_ms     = number
              max_length         = number
            })
          }), null)
          text_input_specification = optional(object({
            start_timeout_ms = number
          }), null)
        })), [])
      })
      declination_response = optional(object({
        allow_interrupt = optional(bool, false)
        message_groups = list(object({
          plain_text_message = string
        }))
      }), null)
    }), null)
    
    closing_setting = optional(object({
      active = optional(bool, true)
      closing_response = optional(object({
        allow_interrupt = optional(bool, false)
        message_groups = list(object({
          plain_text_message = string
        }))
      }), null)
    }), null)
    
    input_contexts = optional(list(string), [])
    
    output_contexts = optional(list(object({
      name                    = string
      time_to_live_in_seconds = number
      turns_to_live           = number
    })), [])
    
    kendra_configuration = optional(object({
      kendra_index                = string
      query_filter_string         = optional(string, null)
      query_filter_string_enabled = optional(bool, false)
    }), null)
  }))
  default = []
}

variable "intent_timeouts" {
  description = "Timeout configuration for intent operations"
  type = object({
    create = optional(string, "30m")
    update = optional(string, "30m")
    delete = optional(string, "30m")
  })
  default = {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}