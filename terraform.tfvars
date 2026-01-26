# AWS Configuration
aws_region = "us-east-1"

# Lex Bot Configuration
bot_name        = "customer-service-bot"
bot_description = "Customer service bot for handling inquiries"

# Privacy Settings
child_directed = false

# Session Configuration
idle_session_ttl_in_seconds = 600

# Bot Type
bot_type = "Bot"

# IAM Configuration
iam_role_name = "customer-service-bot-role"

# Optional: Attach additional IAM policies
iam_policy_arns = [
  # "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
]

# Optional: Bot members (for BotNetwork type)
bot_members = []

# Bot Locales Configuration
bot_locales = [
  {
    locale_id                        = "en_US"
    bot_version                      = "DRAFT"
    n_lu_intent_confidence_threshold = 0.70
    description                      = "English (US) locale for customer service bot"
    voice_settings = {
      voice_id = "Joanna"
      engine   = "neural"
    }
  },
  {
    locale_id                        = "es_US"
    bot_version                      = "DRAFT"
    n_lu_intent_confidence_threshold = 0.70
    description                      = "Spanish (US) locale for customer service bot"
    voice_settings = {
      voice_id = "Lupe"
      engine   = "neural"
    }
  },
  {
    locale_id                        = "fr_FR"
    bot_version                      = "DRAFT"
    n_lu_intent_confidence_threshold = 0.65
    description                      = "French (France) locale for customer service bot"
    voice_settings = {
      voice_id = "Lea"
      engine   = "standard"
    }
  }
]

# Locale Operation Timeouts
locale_timeouts = {
  create = "30m"
  update = "30m"
  delete = "30m"
}

# Bot Intents Configuration
bot_intents = [
  {
    name        = "OrderPizza"
    bot_version = "DRAFT"
    locale_id   = "en_US"
    description = "Intent to order a pizza"
    sample_utterances = [
      "I want to order a pizza",
      "Can I get a pizza",
      "I'd like to order pizza"
    ]
    
    confirmation_setting = {
      active = true
      prompt_specification = {
        max_retries                = 2
        allow_interrupt            = true
        message_selection_strategy = "Ordered"
        message_groups = [
          {
            plain_text_message = "Are you sure you want to order this pizza?"
          }
        ]
        # Include default prompt attempts to avoid AWS drift
        prompt_attempts_specification = [
          {
            allow_interrupt = true
            map_block_key   = "Initial"
            allowed_input_types = {
              allow_audio_input = true
              allow_dtmf_input  = true
            }
            audio_and_dtmf_input_specification = {
              start_timeout_ms = 4000
              audio_specification = {
                end_timeout_ms = 640
                max_length_ms  = 15000
              }
              dtmf_specification = {
                deletion_character = "*"
                end_character      = "#"
                end_timeout_ms     = 5000
                max_length         = 513
              }
            }
            text_input_specification = {
              start_timeout_ms = 30000
            }
          },
          {
            allow_interrupt = true
            map_block_key   = "Retry1"
            allowed_input_types = {
              allow_audio_input = true
              allow_dtmf_input  = true
            }
            audio_and_dtmf_input_specification = {
              start_timeout_ms = 4000
              audio_specification = {
                end_timeout_ms = 640
                max_length_ms  = 15000
              }
              dtmf_specification = {
                deletion_character = "*"
                end_character      = "#"
                end_timeout_ms     = 5000
                max_length         = 513
              }
            }
            text_input_specification = {
              start_timeout_ms = 30000
            }
          }
        ]
      }
      declination_response = {
        allow_interrupt = false
        message_groups = [
          {
            plain_text_message = "Okay, I've cancelled your pizza order."
          }
        ]
      }
    }
    
    closing_setting = {
      active = true
      closing_response = {
        allow_interrupt = false
        message_groups = [
          {
            plain_text_message = "Thank you for your order! Your pizza will be ready soon."
          }
        ]
      }
    }
    
    fulfillment_code_hook = {
      enabled = true
      active  = true
      post_fulfillment_status_specification = {
        success_response = {
          allow_interrupt = false
          message_groups = [
            {
              plain_text_message = "Your order has been placed successfully!"
            }
          ]
        }
      }
    }
  },
  {
    name        = "CheckOrderStatus"
    bot_version = "DRAFT"
    locale_id   = "en_US"
    description = "Intent to check order status"
    sample_utterances = [
      "Where is my order",
      "Check my order status",
      "Track my order"
    ]
    
    dialog_code_hook = {
      enabled = true
    }
    
    closing_setting = {
      active = true
      closing_response = {
        allow_interrupt = false
        message_groups = [
          {
            plain_text_message = "Is there anything else I can help you with?"
          }
        ]
      }
    }
  }
]

# Bot Slots Configuration
bot_slots = [
  {
    name         = "PizzaSize"
    intent_name  = "OrderPizza"
    locale_id    = "en_US"
    bot_version  = "DRAFT"
    description  = "Slot for pizza size selection"
    slot_type_id = "AMAZON.AlphaNumeric"
    
    allow_multiple_values = false
    
    obfuscation_setting = {
      obfuscation_setting_type = "DefaultObfuscation"
    }
    
    value_elicitation_setting = {
      slot_constraint = "Required"
      
      default_value_specification = {
        default_value_list = [
          {
            default_value = "medium"
          }
        ]
      }
      
      prompt_specification = {
        allow_interrupt            = true
        max_retries                = 2
        message_selection_strategy = "Random"
        
        message_groups = [
          {
            plain_text_message = "What size pizza would you like? We have small, medium, and large."
          },
          {
            plain_text_message = "Please choose a pizza size: small, medium, or large."
          }
        ]
        
        prompt_attempts_specification = [
          {
            allow_interrupt = true
            map_block_key   = "Initial"
            allowed_input_types = {
              allow_audio_input = true
              allow_dtmf_input  = false
            }
            audio_and_dtmf_input_specification = {
              start_timeout_ms = 4000
              audio_specification = {
                end_timeout_ms = 640
                max_length_ms  = 15000
              }
              dtmf_specification = {
                deletion_character = "*"
                end_character      = "#"
                end_timeout_ms     = 5000
                max_length         = 513
              }
            }
            text_input_specification = {
              start_timeout_ms = 30000
            }
          },
          {
            allow_interrupt = true
            map_block_key   = "Retry1"
            allowed_input_types = {
              allow_audio_input = true
              allow_dtmf_input  = false
            }
            audio_and_dtmf_input_specification = {
              start_timeout_ms = 4000
              audio_specification = {
                end_timeout_ms = 640
                max_length_ms  = 15000
              }
              dtmf_specification = {
                deletion_character = "*"
                end_character      = "#"
                end_timeout_ms     = 5000
                max_length         = 513
              }
            }
            text_input_specification = {
              start_timeout_ms = 30000
            }
          }
        ]
      }
      
      sample_utterances = [
        {
          utterance = "small"
        },
        {
          utterance = "medium"
        },
        {
          utterance = "large"
        },
        {
          utterance = "extra large"
        }
      ]
      
      slot_resolution_setting = {
        slot_resolution_strategy = "Default"
      }
    }
  },
  {
    name         = "PizzaToppings"
    intent_name  = "OrderPizza"
    locale_id    = "en_US"
    bot_version  = "DRAFT"
    description  = "Slot for pizza toppings selection"
    slot_type_id = "AMAZON.AlphaNumeric"
    
    allow_multiple_values = false
    
    obfuscation_setting = {
      obfuscation_setting_type = "DefaultObfuscation"
    }
    
    value_elicitation_setting = {
      slot_constraint = "Required"
      
      prompt_specification = {
        allow_interrupt            = true
        max_retries                = 2
        message_selection_strategy = "Random"
        
        message_groups = [
          {
            plain_text_message = "What toppings would you like on your pizza? You can choose multiple toppings like pepperoni, mushrooms, onions, or peppers."
          }
        ]
        
        prompt_attempts_specification = [
          {
            allow_interrupt = true
            map_block_key   = "Initial"
            allowed_input_types = {
              allow_audio_input = true
              allow_dtmf_input  = false
            }
            audio_and_dtmf_input_specification = {
              start_timeout_ms = 4000
              audio_specification = {
                end_timeout_ms = 640
                max_length_ms  = 15000
              }
              dtmf_specification = {
                deletion_character = "*"
                end_character      = "#"
                end_timeout_ms     = 5000
                max_length         = 513
              }
            }
            text_input_specification = {
              start_timeout_ms = 30000
            }
          }
        ]
      }
      
      sample_utterances = [
        {
          utterance = "pepperoni"
        },
        {
          utterance = "mushrooms"
        },
        {
          utterance = "onions"
        },
        {
          utterance = "peppers"
        },
        {
          utterance = "cheese"
        },
        {
          utterance = "sausage"
        }
      ]
      
      wait_and_continue_specification = {
        active = true
        
        continue_response = {
          allow_interrupt = true
          message_groups = [
            {
              plain_text_message = "Would you like to add another topping?"
            }
          ]
        }
        
        waiting_response = {
          allow_interrupt = true
          message_groups = [
            {
              plain_text_message = "I'm ready when you are. What toppings would you like?"
            }
          ]
        }
      }
    }
  },
  {
    name         = "OrderNumber"
    intent_name  = "CheckOrderStatus"
    locale_id    = "en_US"
    bot_version  = "DRAFT"
    description  = "Slot for order number input"
    slot_type_id = "AMAZON.Number"
    
    allow_multiple_values = false
    
    obfuscation_setting = {
      obfuscation_setting_type = "None"
    }
    
    value_elicitation_setting = {
      slot_constraint = "Required"
      
      prompt_specification = {
        allow_interrupt            = true
        max_retries                = 2
        message_selection_strategy = "Random"
        
        message_groups = [
          {
            plain_text_message = "Please provide your order number."
          },
          {
            plain_text_message = "What is your order number?"
          }
        ]
        
        prompt_attempts_specification = [
          {
            allow_interrupt = true
            map_block_key   = "Initial"
            allowed_input_types = {
              allow_audio_input = true
              allow_dtmf_input  = true
            }
            audio_and_dtmf_input_specification = {
              start_timeout_ms = 4000
              audio_specification = {
                end_timeout_ms = 640
                max_length_ms  = 15000
              }
              dtmf_specification = {
                deletion_character = "*"
                end_character      = "#"
                end_timeout_ms     = 5000
                max_length         = 513
              }
            }
            text_input_specification = {
              start_timeout_ms = 30000
            }
          }
        ]
      }
      
      slot_resolution_setting = {
        slot_resolution_strategy = "Default"
      }
    }
  }
]

# Slot Operation Timeouts
slot_timeouts = {
  create = "30m"
  update = "30m"
  delete = "30m"
}

# Intent Operation Timeouts
intent_timeouts = {
  create = "30m"
  update = "30m"
  delete = "30m"
}

# Bot Versions Configuration
bot_versions = [
  {
    version_name = "v1"
    description  = "First production version with all locales and intents"
    locale_specification = {
      "en_US" = {
        source_bot_version = "DRAFT"
      },
      "es_US" = {
        source_bot_version = "DRAFT"
      },
      "fr_FR" = {
        source_bot_version = "DRAFT"
      }
    }
  }
]

# Tags
tags = {
  Environment = "production"
  Project     = "customer-service"
  Team        = "platform"
  ManagedBy   = "Terraform"
}