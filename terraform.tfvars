# AWS Configuration
aws_region = "us-east-1"

# Multiple Lex Bots Configuration
lex_bots = {
  # Bot 1: Simple FAQ Bot
  simple_faq_bot = {
    # Basic bot configuration
    bot_name        = "simple-faq-bot"
    bot_description = "Simple FAQ bot for common questions"
    child_directed  = false
    idle_session_ttl_in_seconds = 300
    bot_type        = "Bot"
    
    # IAM Configuration
    iam_role_name = "simple-faq-bot-role"
    iam_policy_arns = []
    
    # Bot members
    bot_members = []
    
    # Bot-specific tags
    tags = {
      Application = "faq"
      Complexity  = "simple"
      Category    = "general-support"
    }
    
    # Single English locale (simplified)
    bot_locales = [
      {
        locale_id                        = "en_US"
        bot_version                      = "DRAFT"
        n_lu_intent_confidence_threshold = 0.70
        description                      = "English locale for FAQ bot"
        voice_settings = {
          voice_id = "Joanna"
          engine   = "neural"
        }
      }
    ]
    
    # Locale timeouts
    locale_timeouts = {
      create = "30m"
      update = "30m"
      delete = "30m"
    }
    
    bot_intents = [
      # Intent 1: Greeting
      {
        name        = "Greeting"
        bot_version = "DRAFT"
        locale_id   = "en_US"
        description = "Greeting intent"
        sample_utterances = [
          "Hello",
          "Hi",
          "Good morning",
          "Good afternoon"
        ]
        
        initial_response_setting = {
          initial_response = {
            allow_interrupt = true
            message_groups = [
              {
                plain_text_message = "Hello! How can I help you today?"
              }
            ]
          }
        }
        
        dialog_code_hook = null
        
        fulfillment_code_hook = {
          enabled = false
          active  = false
        }
        
        confirmation_setting = null
        
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
        
        input_contexts  = []
        output_contexts = []
        kendra_configuration = null
        parent_intent_signature = null
      },
      
      # Intent 2: AskQuestion
      {
        name        = "AskQuestion"
        bot_version = "DRAFT"
        locale_id   = "en_US"
        description = "Intent to ask a question"
        sample_utterances = [
          "I have a question",
          "Can you help me?",
          "I need assistance",
          "Can you answer something?"
        ]

        initial_response_setting = {
          initial_response = {
            allow_interrupt = true
            message_groups = [
              {
                plain_text_message = "Hello! How can I assist you?"
              }
            ]
          }
        }
        
        dialog_code_hook = null
        
        fulfillment_code_hook = {
          enabled = false
          active  = false
        }
        
        confirmation_setting = null
        
        closing_setting = {
          active = true
          closing_response = {
            allow_interrupt = false
            message_groups = [
              {
                plain_text_message = "I'll do my best to answer your question. What would you like to know?"
              }
            ]
          }
        }
        
        input_contexts  = []
        output_contexts = []
        kendra_configuration = null
        parent_intent_signature = null
      }
    ]
    
    # Intent timeouts
    intent_timeouts = {
      create = "30m"
      update = "30m"
      delete = "30m"
    }
    
    bot_slots = [
      {
        name         = "QuestionTopic"
        intent_name  = "AskQuestion"
        locale_id    = "en_US"
        bot_version  = "DRAFT"
        description  = "Slot to capture the question topic"
        slot_type_id = "AMAZON.AlphaNumeric"
        priority     = 1
        
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
                plain_text_message = "What topic would you like to ask about?"
              },
              {
                plain_text_message = "Please tell me what topic your question is about."
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
              utterance = "hours"
            },
            {
              utterance = "pricing"
            },
            {
              utterance = "support"
            },
            {
              utterance = "account"
            }
          ]
          
          slot_resolution_setting = {
            slot_resolution_strategy = "Default"
          }
          
          wait_and_continue_specification = null
        }
        
        sub_slot_setting = null
      }
    ]
    
    # Slot timeouts
    slot_timeouts = {
      create = "30m"
      update = "30m"
      delete = "30m"
    }
    
    #custom slot type
    bot_slot_types = [
      {
        name        = "TopicType"
        locale_id   = "en_US"
        bot_version = "DRAFT"
        description = "Custom slot type for question topics"
        
        parent_slot_type_signature = null
        
        slot_type_values = [
          {
            sample_value = {
              value = "billing"
            }
            synonyms = [
              { value = "payment" },
              { value = "invoice" },
              { value = "charges" }
            ]
          },
          {
            sample_value = {
              value = "technical"
            }
            synonyms = [
              { value = "tech support" },
              { value = "technical issues" },
              { value = "system problems" }
            ]
          }
        ]
        
        value_selection_setting = {
          resolution_strategy = "TopResolution"
          advanced_recognition_setting = null
          regex_filter = null
        }
        
        composite_slot_type_setting = null
        external_source_setting = null
      }
    ]
    
    # Slot type timeouts
    slot_type_timeouts = {
      create = "30m"
      update = "30m"
      delete = "30m"
    }
    
    # bot version
    bot_versions = [
      {
        version_name = "v1"
        description  = "Initial version of the FAQ bot"
        locale_specification = {
          "en_US" = {
            source_bot_version = "DRAFT"
          }
        }
      }
    ]
  },
  
  # Bot 2: Travel Bot
  travel_bot = {
    # Basic bot configuration
    bot_name        = "travelbot2"
    bot_description = "Travel assistance bot for booking and inquiries"
    child_directed  = false
    idle_session_ttl_in_seconds = 600
    bot_type        = "Bot"
    
    # IAM Configuration
    iam_role_name = "travelbot2-role"
    iam_policy_arns = []
    
    # Bot members
    bot_members = []
    
    # Bot-specific tags
    tags = {
      Application = "travel"
      Complexity  = "advanced"
      Category    = "travel-services"
    }
    
    # Single English locale for travel bot
    bot_locales = [
      {
        locale_id                        = "en_US"
        bot_version                      = "DRAFT"
        n_lu_intent_confidence_threshold = 0.75
        description                      = "English locale for travel bot"
        voice_settings = {
          voice_id = "Matthew"
          engine   = "neural"
        }
      }
    ]
    
    # Locale timeouts
    locale_timeouts = {
      create = "30m"
      update = "30m"
      delete = "30m"
    }
    
    # Travel bot intents (5 intents as requested)
    bot_intents = [
      # Intent 1: QnAbotIntent
      {
        name        = "QnAbotIntent"
        bot_version = "DRAFT"
        locale_id   = "en_US"
        description = "General Q&A for travel information"
        sample_utterances = [
          "What travel options do you have?",
          "Tell me about travel packages",
          "What destinations are available?",
          "Travel information please",
          "Help with travel planning"
        ]

        initial_response_setting = {
          initial_response = {
            allow_interrupt = true
            message_groups = [
              {
                plain_text_message = "Welcome to the travel bot! You can ask me about travel options, destinations, and booking assistance."
              }
            ]
          }
        }
        
        dialog_code_hook = null
        
        fulfillment_code_hook = {
          enabled = false
          active  = false
        }
        
        confirmation_setting = null
        
        closing_setting = {
          active = true
          closing_response = {
            allow_interrupt = false
            message_groups = [
              {
                plain_text_message = "I hope that answers your travel questions. Is there anything else you'd like to know?"
              }
            ]
          }
        }
        
        input_contexts  = []
        output_contexts = []
        kendra_configuration = null
        parent_intent_signature = null
      },
      
      # Intent 2: VIP Customer
      {
        name        = "VIPCustomer"
        bot_version = "DRAFT"
        locale_id   = "en_US"
        description = "VIP customer service intent"
        sample_utterances = [
          "I am a VIP customer",
          "VIP service please",
          "Priority assistance",
          "I have VIP status",
          "VIP customer support"
        ]

        initial_response_setting = {
          initial_response = {
            allow_interrupt = true
            message_groups = [
              {
                plain_text_message = "Hello! Thank you for being a VIP customer. How can I assist you today?"
              }
            ]
          }
        }
        
        dialog_code_hook = null
        
        fulfillment_code_hook = {
          enabled = false
          active  = false
        }
        
        confirmation_setting = null
        
        closing_setting = {
          active = true
          closing_response = {
            allow_interrupt = false
            message_groups = [
              {
                plain_text_message = "Thank you for being a VIP customer! Your request has been prioritized."
              }
            ]
          }
        }
        
        input_contexts  = []
        output_contexts = []
        kendra_configuration = null
        parent_intent_signature = null
      },
      
      # Intent 3: SpeaktoAgent
      {
        name        = "SpeaktoAgent"
        bot_version = "DRAFT"
        locale_id   = "en_US"
        description = "Request to speak with a human agent"
        sample_utterances = [
          "I want to speak to an agent",
          "Connect me to a human",
          "Can I talk to a representative?",
          "Human agent please",
          "Transfer to customer service"
        ]
        
        initial_response_setting = {
          initial_response = {
            allow_interrupt = true
            message_groups = [
              {
                plain_text_message = "Let me connect you with an agent."
              }
            ]
          }
        }
        
        dialog_code_hook = null
        
        fulfillment_code_hook = {
          enabled = false
          active  = false
        }
        
        confirmation_setting = null
        
        closing_setting = {
          active = true
          closing_response = {
            allow_interrupt = false
            message_groups = [
              {
                plain_text_message = "I'll connect you with a live agent now. Please hold."
              }
            ]
          }
        }
        
        input_contexts  = []
        output_contexts = []
        kendra_configuration = null
        parent_intent_signature = null
      },
      
      # Intent 4: BookTickets
      {
        name        = "BookTickets"
        bot_version = "DRAFT"
        locale_id   = "en_US"
        description = "Intent to book travel tickets"
        sample_utterances = [
          "I want to book tickets",
          "Book a flight",
          "Reserve train tickets",
          "Purchase bus tickets",
          "I need to book travel"
        ]

        initial_response_setting = {
          initial_response = {
            allow_interrupt = true
            message_groups = [
              {
                plain_text_message = "Starting the ticket booking process. Please provide your travel details."
              }
            ]
          }
        }
        
        dialog_code_hook = null
        
        fulfillment_code_hook = {
          enabled = false
          active  = false
        }
        
        confirmation_setting = {
          active = true
          prompt_specification = {
            max_retries                = 2
            allow_interrupt            = true
            message_selection_strategy = "Random"
            message_groups = [
              {
                plain_text_message = "Are you sure you want to book these tickets?"
              },
              {
                plain_text_message = "Confirm your booking?"
              }
            ]
            prompt_attempts_specification = []
          }
          declination_response = null
        }
        
        closing_setting = {
          active = true
          closing_response = {
            allow_interrupt = false
            message_groups = [
              {
                plain_text_message = "Your tickets have been booked successfully! You will receive a confirmation email shortly."
              }
            ]
          }
        }
        
        input_contexts  = []
        output_contexts = []
        kendra_configuration = null
        parent_intent_signature = null
      },
      
      # Intent 5: GetDepartureLocations
      {
        name        = "GetDepartureLocations"
        bot_version = "DRAFT"
        locale_id   = "en_US"
        description = "Get available departure locations"
        sample_utterances = [
          "Where can I depart from?",
          "Show departure locations",
          "What cities can I leave from?",
          "Available departure points",
          "List departure cities"
        ]
        
        initial_response_setting = {
          initial_response = {
            allow_interrupt = true
            message_groups = [
              {
                plain_text_message = "Let me show you the available departure locations."
              }
            ]
          }
        }
        
        dialog_code_hook = null
        
        fulfillment_code_hook = {
          enabled = false
          active  = false
        }
        
        confirmation_setting = null
        
        closing_setting = {
          active = true
          closing_response = {
            allow_interrupt = false
            message_groups = [
              {
                plain_text_message = "Here are the available departure locations. Which one would you like to choose?"
              }
            ]
          }
        }
        
        input_contexts  = []
        output_contexts = []
        kendra_configuration = null
        parent_intent_signature = null
      }
    ]
    
    # Intent timeouts
    intent_timeouts = {
      create = "30m"
      update = "30m"
      delete = "30m"
    }
    
    # Slots for travel bot
    bot_slots = [
      # Slot for BookTickets intent
      {
        name         = "Destination"
        intent_name  = "BookTickets"
        locale_id    = "en_US"
        bot_version  = "DRAFT"
        description  = "Travel destination"
        slot_type_id = "AMAZON.City"
        priority     = 2
        
        allow_multiple_values = false
        
        obfuscation_setting = null
        
        value_elicitation_setting = {
          slot_constraint = "Required"
          
          default_value_specification = null
          
          prompt_specification = {
            allow_interrupt            = true
            max_retries                = 2
            message_selection_strategy = "Random"
            
            message_groups = [
              {
                plain_text_message = "Where would you like to travel to?"
              },
              {
                plain_text_message = "Please tell me your destination city."
              }
            ]
            
            prompt_attempts_specification = null
          }
          
          sample_utterances = [
            {
              utterance = "New York"
            },
            {
              utterance = "London"
            },
            {
              utterance = "Tokyo"
            }
          ]
          
          slot_resolution_setting = null
          wait_and_continue_specification = null
        }
        
        sub_slot_setting = null
      },
      
      # Slot for BookTickets intent - Travel Date
      {
        name         = "TravelDate"
        intent_name  = "BookTickets"
        locale_id    = "en_US"
        bot_version  = "DRAFT"
        description  = "Date of travel"
        slot_type_id = "AMAZON.Date"
        priority     = 1
        
        allow_multiple_values = false
        
        obfuscation_setting = null
        
        value_elicitation_setting = {
          slot_constraint = "Required"
          
          default_value_specification = null
          
          prompt_specification = {
            allow_interrupt            = true
            max_retries                = 2
            message_selection_strategy = "Random"
            
            message_groups = [
              {
                plain_text_message = "When would you like to travel?"
              },
              {
                plain_text_message = "Please provide your travel date."
              }
            ]
            
            prompt_attempts_specification = null
          }
          
          sample_utterances = null
          slot_resolution_setting = null
          wait_and_continue_specification = null
        }
        
        sub_slot_setting = null
      },
      
      # Slot for GetDepartureLocations intent
      {
        name         = "DepartureCity"
        intent_name  = "GetDepartureLocations"
        locale_id    = "en_US"
        bot_version  = "DRAFT"
        description  = "Departure city for travel"
        slot_type_id = "AMAZON.City"
        priority     = 1
        
        allow_multiple_values = false
        
        obfuscation_setting = null
        
        value_elicitation_setting = {
          slot_constraint = "Optional"
          
          default_value_specification = null
          
          prompt_specification = {
            allow_interrupt            = true
            max_retries                = 1
            message_selection_strategy = "Random"
            
            message_groups = [
              {
                plain_text_message = "Which city are you departing from? (optional)"
              }
            ]
            
            prompt_attempts_specification = null
          }
          
          sample_utterances = null
          slot_resolution_setting = null
          wait_and_continue_specification = null
        }
        
        sub_slot_setting = null
      }
    ]
    
    # Slot timeouts
    slot_timeouts = {
      create = "30m"
      update = "30m"
      delete = "30m"
    }
    
    # Custom slot types for travel bot
    bot_slot_types = [
      {
        name        = "TravelClass"
        locale_id   = "en_US"
        bot_version = "DRAFT"
        description = "Travel class options"
        
        parent_slot_type_signature = null
        
        slot_type_values = [
          {
            sample_value = {
              value = "economy"
            }
            synonyms = [
              { value = "standard" },
              { value = "basic" },
              { value = "regular" }
            ]
          },
          {
            sample_value = {
              value = "business"
            }
            synonyms = [
              { value = "business class" },
              { value = "premium" },
              { value = "executive" }
            ]
          },
          {
            sample_value = {
              value = "first"
            }
            synonyms = [
              { value = "first class" },
              { value = "luxury" },
              { value = "premium plus" }
            ]
          }
        ]
        
        value_selection_setting = {
          resolution_strategy = "TopResolution"
          advanced_recognition_setting = null
          regex_filter = null
        }
        
        composite_slot_type_setting = null
        external_source_setting = null
      }
    ]
    
    # Slot type timeouts
    slot_type_timeouts = {
      create = "30m"
      update = "30m"
      delete = "30m"
    }
    
    # Bot versions for travel bot
    bot_versions = [
      {
        version_name = "v1"
        description  = "Initial version of travel bot"
        locale_specification = {
          "en_US" = {
            source_bot_version = "DRAFT"
          }
        }
      }
    ]
  }
}