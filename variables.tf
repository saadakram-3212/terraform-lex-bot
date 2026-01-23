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