variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "bot_name" {
  description = "Name of the Lex bot"
  type        = string
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
}

variable "bot_type" {
  description = "Type of the bot (Bot or BotNetwork)"
  type        = string
  default     = "Bot"
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

variable "bot_slots" {
  description = "List of slots to create for bot intents"
  type = list(object({
    name                = string
    intent_name         = string
    locale_id          = string
    bot_version        = optional(string, "DRAFT")
    description        = optional(string, "")
    slot_type_id       = optional(string, null)
    
    # Multiple values setting
    allow_multiple_values = optional(bool, false)
    
    # Obfuscation setting
    obfuscation_setting = optional(object({
      obfuscation_setting_type = optional(string, "DefaultObfuscation")
    }), null)
    
    # Value elicitation setting (Required)
    value_elicitation_setting = object({
      slot_constraint = string # Required or Optional
      
      default_value_specification = optional(object({
        default_value_list = optional(list(object({
          default_value = string
        })), [])
      }), null)
      
      prompt_specification = optional(object({
        allow_interrupt            = optional(bool, true)
        max_retries                = optional(number, 3)
        message_selection_strategy = optional(string, "Random")
        
        message_groups = optional(list(object({
          plain_text_message = string
        })), [])
        
        prompt_attempts_specification = optional(list(object({
          allow_interrupt = optional(bool, true)
          map_block_key   = string
          
          allowed_input_types = optional(object({
            allow_audio_input = optional(bool, true)
            allow_dtmf_input  = optional(bool, false)
          }), {
            allow_audio_input = true
            allow_dtmf_input  = false
          })
          
          audio_and_dtmf_input_specification = optional(object({
            start_timeout_ms = optional(number, 4000)
            
            audio_specification = optional(object({
              end_timeout_ms = optional(number, 640)
              max_length_ms  = optional(number, 15000)
            }), {
              end_timeout_ms = 640
              max_length_ms  = 15000
            })
            
            dtmf_specification = optional(object({
              deletion_character = optional(string, "*")
              end_character      = optional(string, "#")
              end_timeout_ms     = optional(number, 5000)
              max_length         = optional(number, 513)
            }), {
              deletion_character = "*"
              end_character      = "#"
              end_timeout_ms     = 5000
              max_length         = 513
            })
          }), null)
          
          text_input_specification = optional(object({
            start_timeout_ms = optional(number, 30000)
          }), null)
        })), [])
      }), null)
      
      sample_utterances = optional(list(object({
        utterance = string
      })), [])
      
      slot_resolution_setting = optional(object({
        slot_resolution_strategy = optional(string, "Default")
      }), null)
      
      wait_and_continue_specification = optional(object({
        active = optional(bool, true)
        
        continue_response = optional(object({
          allow_interrupt = optional(bool, false)
          message_groups = optional(list(object({
            plain_text_message = string
          })), [])
        }), null)
        
        waiting_response = optional(object({
          allow_interrupt = optional(bool, false)
          message_groups = optional(list(object({
            plain_text_message = string
          })), [])
        }), null)
        
        still_waiting_response = optional(object({
          frequency_in_seconds = number
          timeout_in_seconds   = number
          allow_interrupt      = optional(bool, false)
          message_groups = optional(list(object({
            plain_text_message = string
          })), [])
        }), null)
      }), null)
    })
    
    # Sub-slot setting
    sub_slot_setting = optional(object({
      expression = optional(string, null)
      
      slot_specification = optional(map(object({
        slot_type_id = string
        
        value_elicitation_setting = optional(object({
          slot_constraint = optional(string, "Required")
          
          default_value_specification = optional(object({
            default_value_list = optional(list(object({
              default_value = string
            })), [])
          }), null)
          
          prompt_specification = optional(object({
            allow_interrupt            = optional(bool, true)
            max_retries                = optional(number, 3)
            message_selection_strategy = optional(string, "Random")
            
            message_groups = optional(list(object({
              plain_text_message = string
            })), [])
            
            prompt_attempts_specification = optional(list(object({
              allow_interrupt = optional(bool, true)
              map_block_key   = string
              
              allowed_input_types = optional(object({
                allow_audio_input = optional(bool, true)
                allow_dtmf_input  = optional(bool, false)
              }), {
                allow_audio_input = true
                allow_dtmf_input  = false
              })
              
              audio_and_dtmf_input_specification = optional(object({
                start_timeout_ms = optional(number, 4000)
                
                audio_specification = optional(object({
                  end_timeout_ms = optional(number, 640)
                  max_length_ms  = optional(number, 15000)
                }), {
                  end_timeout_ms = 640
                  max_length_ms  = 15000
                })
                
                dtmf_specification = optional(object({
                  deletion_character = optional(string, "*")
                  end_character      = optional(string, "#")
                  end_timeout_ms     = optional(number, 5000)
                  max_length         = optional(number, 513)
                }), {
                  deletion_character = "*"
                  end_character      = "#"
                  end_timeout_ms     = 5000
                  max_length         = 513
                })
              }), null)
              
              text_input_specification = optional(object({
                start_timeout_ms = optional(number, 30000)
              }), null)
            })), [])
          }), null)
          
          sample_utterances = optional(list(object({
            utterance = string
          })), [])
          
          slot_resolution_setting = optional(object({
            slot_resolution_strategy = optional(string, "Default")
          }), null)
          
          wait_and_continue_specification = optional(object({
            active = optional(bool, true)
            
            continue_response = optional(object({
              allow_interrupt = optional(bool, false)
              message_groups = optional(list(object({
                plain_text_message = string
              })), [])
            }), null)
            
            waiting_response = optional(object({
              allow_interrupt = optional(bool, false)
              message_groups = optional(list(object({
                plain_text_message = string
              })), [])
            }), null)
            
            still_waiting_response = optional(object({
              frequency_in_seconds = number
              timeout_in_seconds   = number
              allow_interrupt      = optional(bool, false)
              message_groups = optional(list(object({
                plain_text_message = string
              })), [])
            }), null)
          }), null)
        }), {
          slot_constraint = "Required"
        })
      })), {})
    }), null)
  }))
  default = []
}

variable "slot_timeouts" {
  description = "Timeout configuration for slot operations"
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

variable "bot_slot_types" {
  description = "List of custom slot types to create for the bot"
  type = list(object({
    name        = string
    locale_id   = string
    bot_version = optional(string, "DRAFT")
    description = optional(string, "")
    
    # Parent slot type signature for inheritance
    parent_slot_type_signature = optional(string, null)
    
    # Slot type values configuration
    slot_type_values = optional(list(object({
      sample_value = object({
        value = string
      })
      synonyms = optional(list(object({
        value = string
      })), [])
    })), [])
    
    # Value selection setting
    value_selection_setting = optional(object({
      resolution_strategy = optional(string, "OriginalValue")
      
      advanced_recognition_setting = optional(object({
        audio_recognition_strategy = optional(string, null)
      }), null)
      
      regex_filter = optional(object({
        pattern = string
      }), null)
    }), {
      resolution_strategy = "OriginalValue"
    })
    
    # Composite slot type setting
    composite_slot_type_setting = optional(object({
      sub_slots = optional(list(object({
        name        = string
        slot_type_id = string
      })), [])
    }), null)
    
    # External source setting (for grammar-based slot types)
    external_source_setting = optional(object({
      grammar_slot_type_setting = optional(object({
        source = optional(object({
          s3_bucket_name = string
          s3_object_key  = string
          kms_key_arn    = optional(string, null)
        }), null)
      }), null)
    }), null)
  }))
  default = []
}

variable "slot_type_timeouts" {
  description = "Timeout configuration for slot type operations"
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