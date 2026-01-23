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

# Locale Operation Timeouts (optional - uses defaults if not specified)
locale_timeouts = {
  create = "30m"
  update = "30m"
  delete = "30m"
}

# Bot Versions Configuration
# Create versions after locales are configured in DRAFT
bot_versions = [
  {
    version_name = "v1"
    description  = "First production version with all three locales"
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