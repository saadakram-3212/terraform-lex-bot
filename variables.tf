variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "lex_bots" {
  description = "Map of Lex bot configurations"
  type = map(object({
    # Basic bot configuration
    bot_name                    = string
    bot_description             = optional(string)
    child_directed              = optional(bool)
    idle_session_ttl_in_seconds = optional(number)
    bot_type                    = optional(string)
    create_bot_alias          = bool
    bot_alias_name             = optional(string)
    bot_alias_version          = optional(string)
    bot_alias_description      = optional(string)

    
    bot_members = optional(list(object({
      alias_id   = string
      alias_name = string
      id         = string
      name       = string
      version    = string
    })), [])

    
    bot_locales = optional(list(object({
      locale_id                        = string
      bot_version                      = optional(string)
      n_lu_intent_confidence_threshold = number
      description                      = optional(string)
      voice_settings = optional(object({
        voice_id = string
        engine   = optional(string)
      }), null)
    })), [])

    
    locale_timeouts = optional(object({
      create = optional(string)
      update = optional(string)
      delete = optional(string)
      }))

    # Intents
    bot_intents = optional(list(object({
      name                    = string
      bot_version             = optional(string)
      locale_id               = string
      description             = optional(string)
      sample_utterances       = optional(list(string))
      parent_intent_signature = optional(string)

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
          }))
        }))
      }))

      confirmation_setting = optional(object({
        active = optional(bool, true)
        prompt_specification = object({
          max_retries                = number
          allow_interrupt            = optional(bool)
          message_selection_strategy = optional(string)
          message_groups = list(object({
            plain_text_message = string
          }))
          prompt_attempts_specification = optional(list(object({
            allow_interrupt = optional(bool)
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
          allow_interrupt = optional(bool)
          message_groups = list(object({
            plain_text_message = string
          }))
        }), null)
      }), null)

      closing_setting = optional(object({
        active = optional(bool)
        closing_response = optional(object({
          allow_interrupt = optional(bool)
          message_groups = list(object({
            plain_text_message = string
          }))
        }))
      }))

      input_contexts = optional(list(string), [])

      output_contexts = optional(list(object({
        name                    = string
        time_to_live_in_seconds = number
        turns_to_live           = number
      })), [])

      kendra_configuration = optional(object({
        kendra_index                = string
        query_filter_string         = optional(string)
        query_filter_string_enabled = optional(bool)
      }))
    })))

    intent_timeouts = optional(object({
      create = optional(string)
      update = optional(string)
      delete = optional(string)
      }))

    # Slots
    bot_slots = optional(list(object({
      name         = string
      intent_name  = string
      locale_id    = string
      bot_version  = optional(string)
      description  = optional(string)
      slot_type_id = optional(string)
      priority     = optional(number)

      allow_multiple_values = optional(bool, false)

      obfuscation_setting = optional(object({
        obfuscation_setting_type = optional(string)
      }))

      value_elicitation_setting = object({
        slot_constraint = string

        default_value_specification = optional(object({
          default_value_list = optional(list(object({
            default_value = string
          })))
        }))

        prompt_specification = optional(object({
          allow_interrupt            = optional(bool)
          max_retries                = optional(number)
          message_selection_strategy = optional(string)

          message_groups = optional(list(object({
            plain_text_message = string
          })), [])

          prompt_attempts_specification = optional(list(object({
            allow_interrupt = optional(bool)
            map_block_key   = string

            allowed_input_types = optional(object({
              allow_audio_input = optional(bool)
              allow_dtmf_input  = optional(bool)
              }), {
              allow_audio_input = true
              allow_dtmf_input  = false
            })

            audio_and_dtmf_input_specification = optional(object({
              start_timeout_ms = optional(number)

              audio_specification = optional(object({
                end_timeout_ms = optional(number)
                max_length_ms  = optional(number)
                }))

              dtmf_specification = optional(object({
                deletion_character = optional(string)
                end_character      = optional(string)
                end_timeout_ms     = optional(number)
                max_length         = optional(number)
                }))
            }))

            text_input_specification = optional(object({
              start_timeout_ms = optional(number)
            }))
          })))
        }))

        sample_utterances = optional(list(object({
          utterance = string
        })))

        slot_resolution_setting = optional(object({
          slot_resolution_strategy = optional(string)
        }))

        wait_and_continue_specification = optional(object({
          active = optional(bool)

          continue_response = optional(object({
            allow_interrupt = optional(bool)
            message_groups = optional(list(object({
              plain_text_message = string
            })))
          }))

          waiting_response = optional(object({
            allow_interrupt = optional(bool)
            message_groups = optional(list(object({
              plain_text_message = string
            })))
          }))

          still_waiting_response = optional(object({
            frequency_in_seconds = number
            timeout_in_seconds   = number
            allow_interrupt      = optional(bool)
            message_groups = optional(list(object({
              plain_text_message = string
            })))
          }))
        }))
      })

      sub_slot_setting = optional(object({
        expression = optional(string)

        slot_specification = optional(map(object({
          slot_type_id = string

          value_elicitation_setting = optional(object({
            slot_constraint = optional(string)

            default_value_specification = optional(object({
              default_value_list = optional(list(object({
                default_value = string
              })))
            }))

            prompt_specification = optional(object({
              allow_interrupt            = optional(bool)
              max_retries                = optional(number)
              message_selection_strategy = optional(string)

              message_groups = optional(list(object({
                plain_text_message = string
              })))

              prompt_attempts_specification = optional(list(object({
                allow_interrupt = optional(bool)
                map_block_key   = string

                allowed_input_types = optional(object({
                  allow_audio_input = optional(bool)
                  allow_dtmf_input  = optional(bool)
                  }), {
                  allow_audio_input = true
                  allow_dtmf_input  = false
                })

                audio_and_dtmf_input_specification = optional(object({
                  start_timeout_ms = optional(number)

                  audio_specification = optional(object({
                    end_timeout_ms = optional(number)
                    max_length_ms  = optional(number)
                    }))

                  dtmf_specification = optional(object({
                    deletion_character = optional(string)
                    end_character      = optional(string)
                    end_timeout_ms     = optional(number)
                    max_length         = optional(number)
                    }))
                }))

                text_input_specification = optional(object({
                  start_timeout_ms = optional(number)
                }))
              })))
            }))

            sample_utterances = optional(list(object({
              utterance = string
            })))

            slot_resolution_setting = optional(object({
              slot_resolution_strategy = optional(string)
            }))

            wait_and_continue_specification = optional(object({
              active = optional(bool)

              continue_response = optional(object({
                allow_interrupt = optional(bool)
                message_groups = optional(list(object({
                  plain_text_message = string
                })))
              }))

              waiting_response = optional(object({
                allow_interrupt = optional(bool)
                message_groups = optional(list(object({
                  plain_text_message = string
                })))
              }))

              still_waiting_response = optional(object({
                frequency_in_seconds = number
                timeout_in_seconds   = number
                allow_interrupt      = optional(bool)
                message_groups = optional(list(object({
                  plain_text_message = string
                })))
              }))
            }))
            }))
        })))
      }))
    })))

    slot_timeouts = optional(object({
      create = optional(string)
      update = optional(string)
      delete = optional(string)
      }))

    # Slot Types
    bot_slot_types = optional(list(object({
      name        = string
      locale_id   = string
      bot_version = optional(string)
      description = optional(string)

      parent_slot_type_signature = optional(string)

      slot_type_values = optional(list(object({
        sample_value = object({
          value = string
        })
        synonyms = optional(list(object({
          value = string
        })))
      })))

      value_selection_setting = optional(object({
        resolution_strategy = optional(string)

        advanced_recognition_setting = optional(object({
          audio_recognition_strategy = optional(string)
        }))

        regex_filter = optional(object({
          pattern = string
        }))
        }))

      composite_slot_type_setting = optional(object({
        sub_slots = optional(list(object({
          name         = string
          slot_type_id = string
        })))
      }))

      external_source_setting = optional(object({
        grammar_slot_type_setting = optional(object({
          source = optional(object({
            s3_bucket_name = string
            s3_object_key  = string
            kms_key_arn    = optional(string)
          }))
        }))
      }))
    })))

    slot_type_timeouts = optional(object({
      create = optional(string)
      update = optional(string)
      delete = optional(string)
      }))

    # Bot Versions
    bot_versions = optional(list(object({
      version_name = string
      description  = optional(string)
      locale_specification = map(object({
        source_bot_version = string
      }))
    })))

    knowledge_base_intent_enabled = optional(bool)

    # QnA Intent Configuration using Bedrock Knowledge Base
    # VARIABLE NAMES SHOULD NOT BE CHANGED
knowledge_base_intents = optional(list(object({
  intent_name       = string
  description       = optional(string)
  knowledge_base_arn = string
  locale_id         = string
  modelArn = string
  sample_utterances = optional(list(string))
  intent_closing_setting = optional(object({
    active = optional(bool)
    closingResponse = optional(object({  
      allowInterrupt = optional(bool)
      messageGroups = optional(list(object({
        message = object({
          plainTextMessage = optional(object({
            value = string
          }))
        })
      })))
    }))
  }))
})))
    # Tags (merged with global tags)
    tags = optional(map(string))
  }))
}