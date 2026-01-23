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

# Tags
tags = {
  Environment = "production"
  Project     = "customer-service"
  Team        = "platform"
  ManagedBy   = "Terraform"
}