variable "bot_name" {
  type        = string
  description = "Name of the Lex bot"
}

variable "bot_description" {
  type        = string
  description = "Description of the Lex bot"
}

variable "role_arn" {
  type        = string
  description = "ARN of the IAM role for the Lex bot"
}

variable "child_directed" {
  type        = bool
  description = "Whether the bot is directed at children"
}

variable "idle_session_ttl_in_seconds" {
  type        = number
  description = "Time in seconds that the bot should keep the session active"
}

variable "bot_type" {
  type        = string
  description = "Type of the bot"
}


variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
}

variable "bot_members" {
  type = list(object({
    alias_id   = string
    alias_name = string
    id         = string
    name       = string
    version    = string
  }))
  description = "List of bot members for collaboration"
}

variable "bot_locales" {
  type = list(object({
    locale_id                        = string
    bot_version                      = string
    n_lu_intent_confidence_threshold = number
    description                      = optional(string)
    voice_settings = optional(object({
      voice_id = string
      engine   = string
    }))
  }))
  description = "List of bot locales"
}

variable "bot_intents" {
  type = list(object({
    name              = string
    bot_version       = string
    locale_id         = string
    description       = optional(string)
    sample_utterances = list(string)

    initial_response_setting = optional(object({
      initial_response = optional(object({
        allow_interrupt = bool
        message_groups = list(object({
          plain_text_message = string
        }))
      }))
    }))

    dialog_code_hook = optional(object({
      enabled = bool
    }))

    fulfillment_code_hook = optional(object({
      enabled = bool
      active  = bool
      post_fulfillment_status_specification = optional(object({
        success_response = optional(object({
          allow_interrupt = bool
          message_groups = list(object({
            plain_text_message = string
          }))
        }))
      }))
    }))

    confirmation_setting = optional(object({
      active = bool
      prompt_specification = object({
        max_retries                = number
        allow_interrupt            = bool
        message_selection_strategy = string
        message_groups = list(object({
          plain_text_message = string
        }))
        prompt_attempts_specification = optional(list(object({
          allow_interrupt = bool
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
          }))
          text_input_specification = optional(object({
            start_timeout_ms = number
          }))
        })))
      })
      declination_response = optional(object({
        allow_interrupt = bool
        message_groups = list(object({
          plain_text_message = string
        }))
      }))
    }))

    closing_setting = optional(object({
      active = bool
      closing_response = optional(object({
        allow_interrupt = bool
        message_groups = list(object({
          plain_text_message = string
        }))
      }))
    }))

    input_contexts = optional(list(string))

    output_contexts = optional(list(object({
      name                    = string
      time_to_live_in_seconds = number
      turns_to_live           = number
    })))

    kendra_configuration = optional(object({
      kendra_index                = string
      query_filter_string         = optional(string)
      query_filter_string_enabled = optional(bool)
    }))

    parent_intent_signature = optional(string)
  }))
  description = "List of bot intents"
}

variable "bot_slots" {
  type = list(object({
    name         = string
    intent_name  = string
    locale_id    = string
    bot_version  = string
    description  = optional(string)
    slot_type_id = optional(string)
    priority     = optional(number)
    # Multiple values setting
    allow_multiple_values = optional(bool)

    # Obfuscation setting
    obfuscation_setting = optional(object({
      obfuscation_setting_type = string
    }))

    # Value elicitation setting (Required)
    value_elicitation_setting = object({
      slot_constraint = string # Required or Optional

      default_value_specification = optional(object({
        default_value_list = list(object({
          default_value = string
        }))
      }))

      prompt_specification = optional(object({
        allow_interrupt            = bool
        max_retries                = number
        message_selection_strategy = string

        message_groups = list(object({
          plain_text_message = string
        }))

        prompt_attempts_specification = optional(list(object({
          allow_interrupt = bool
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
          }))

          text_input_specification = optional(object({
            start_timeout_ms = number
          }))
        })))
      }))

      sample_utterances = optional(list(object({
        utterance = string
      })))

      slot_resolution_setting = optional(object({
        slot_resolution_strategy = string
      }))

      wait_and_continue_specification = optional(object({
        active = optional(bool, true)

        continue_response = object({
          allow_interrupt = optional(bool)
          message_groups = list(object({
            plain_text_message = string
          }))
        })

        waiting_response = object({
          allow_interrupt = optional(bool)
          message_groups = list(object({
            plain_text_message = string
          }))
        })

        still_waiting_response = optional(object({
          frequency_in_seconds = number
          timeout_in_seconds   = number
          allow_interrupt      = optional(bool)
          message_groups = list(object({
            plain_text_message = string
          }))
        }))
      }))
    })

    # Sub-slot setting
    sub_slot_setting = optional(object({
      expression = optional(string)

      slot_specification = optional(map(object({
        slot_type_id = string

        value_elicitation_setting = object({
          slot_constraint = string

          default_value_specification = optional(object({
            default_value_list = list(object({
              default_value = string
            }))
          }))

          prompt_specification = optional(object({
            allow_interrupt            = bool
            max_retries                = number
            message_selection_strategy = string

            message_groups = list(object({
              plain_text_message = string
            }))

            prompt_attempts_specification = optional(list(object({
              allow_interrupt = bool
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
              }))

              text_input_specification = optional(object({
                start_timeout_ms = number
              }))
            })))
          }))

          sample_utterances = optional(list(object({
            utterance = string
          })))

          slot_resolution_setting = optional(object({
            slot_resolution_strategy = string
          }))

          wait_and_continue_specification = optional(object({
            active = optional(bool)

            continue_response = object({
              allow_interrupt = optional(bool)
              message_groups = list(object({
                plain_text_message = string
              }))
            })

            waiting_response = object({
              allow_interrupt = optional(bool)
              message_groups = list(object({
                plain_text_message = string
              }))
            })

            still_waiting_response = optional(object({
              frequency_in_seconds = number
              timeout_in_seconds   = number
              allow_interrupt      = optional(bool)
              message_groups = list(object({
                plain_text_message = string
              }))
            }))
          }))
        })
      })))
    }))
  }))
}

variable "bot_versions" {
  type = list(object({
    version_name = string
    description  = optional(string)
    locale_specification = map(object({
      source_bot_version = string
    }))
  }))
  description = "List of bot versions"
}

variable "locale_timeouts" {
  type = object({
    create = optional(string)
    update = optional(string)
    delete = optional(string)
  })
}

variable "intent_timeouts" {
  type = object({
    create = optional(string)
    update = optional(string)
    delete = optional(string)
  })
}

variable "slot_timeouts" {
  type = object({
    create = optional(string)
    update = optional(string)
    delete = optional(string)
  })
}

variable "bot_slot_types" {
  description = "List of custom slot types to create for the bot"
  type = list(object({
    name        = string
    locale_id   = string
    bot_version = optional(string)
    description = optional(string)

    # Parent slot type signature for inheritance
    parent_slot_type_signature = optional(string)

    # Slot type values configuration
    slot_type_values = optional(list(object({
      sample_value = object({
        value = string
      })
      synonyms = optional(list(object({
        value = string
      })))
    })))

    # Value selection setting
    value_selection_setting = optional(object({
      resolution_strategy = optional(string)

      advanced_recognition_setting = optional(object({
        audio_recognition_strategy = optional(string)
      }))

      regex_filter = optional(object({
        pattern = string
      }))
      }))

    # Composite slot type setting
    composite_slot_type_setting = optional(object({
      sub_slots = optional(list(object({
        name         = string
        slot_type_id = string
      })))
    }))

    # External source setting (for grammar-based slot types)
    external_source_setting = optional(object({
      grammar_slot_type_setting = optional(object({
        source = optional(object({
          s3_bucket_name = string
          s3_object_key  = string
          kms_key_arn    = optional(string)
        }))
      }))
    }))
  }))
}

variable "slot_type_timeouts" {
  description = "Timeout configuration for slot type operations"
  type = object({
    create = optional(string)
    update = optional(string)
    delete = optional(string)
  })
}

variable "knowledge_base_intent_enabled" {
  description = "Flag to enable or disable the knowledge base intent"
  type        = bool
  default     = false
}


variable "knowledge_base_intents" {
  description = "List of QnA intents using Bedrock Knowledge Base"
  type = list(object({
    intent_name        = string
    description        = optional(string, "Intent for handling questions using Bedrock Knowledge Base")
    locale_id          = string
    knowledge_base_arn = string
    sample_utterances  = optional(list(string), [])
    intent_closing_setting = optional(any)
    modelArn = string
  }))
  default = []
}


variable "create_bot_alias" {
  description = "Flag to create a bot alias"
  type        = bool
}

variable "bot_alias_name" {
  description = "Name of the bot alias"
  type        = string
}

variable "bot_alias_version" {
  description = "Version of the bot for the alias"
  type        = string
}

variable "bot_alias_description" {
  description = "Description of the bot alias"
  type        = string
}