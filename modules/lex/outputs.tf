output "bot_id" {
  description = "ID of the Lex bot"
  value       = aws_lexv2models_bot.this.id
}

output "bot_arn" {
  description = "ARN of the Lex bot"
  value       = aws_lexv2models_bot.this.arn
}

output "bot_name" {
  description = "Name of the Lex bot"
  value       = aws_lexv2models_bot.this.name
}

output "iam_role_arn" {
  description = "ARN of the IAM role created for the Lex bot"
  value       = aws_iam_role.lex_bot.arn
}

output "iam_role_name" {
  description = "Name of the IAM role created for the Lex bot"
  value       = aws_iam_role.lex_bot.name
}

output "iam_role_id" {
  description = "ID of the IAM role created for the Lex bot"
  value       = aws_iam_role.lex_bot.id
}

output "bot_locales" {
  description = "Map of bot locale IDs to their full resource objects"
  value       = aws_lexv2models_bot_locale.this
}

output "bot_locale_ids" {
  description = "List of bot locale IDs"
  value       = [for locale in aws_lexv2models_bot_locale.this : locale.id]
}

output "bot_locale_names" {
  description = "Map of locale IDs to their names"
  value       = { for k, locale in aws_lexv2models_bot_locale.this : k => locale.name }
}

output "bot_versions" {
  description = "Map of bot versions"
  value       = aws_lexv2models_bot_version.this
}

output "bot_version_ids" {
  description = "List of bot version IDs"
  value       = [for version in aws_lexv2models_bot_version.this : version.id]
}

output "bot_version_numbers" {
  description = "Map of version names to version numbers"
  value       = { for k, version in aws_lexv2models_bot_version.this : k => version.bot_version }
}

output "bot_intents" {
  description = "Map of bot intents"
  value       = aws_lexv2models_intent.this
  sensitive   = false
}

output "bot_intent_ids" {
  description = "Map of intent names to their IDs"
  value       = { for k, intent in aws_lexv2models_intent.this : k => intent.intent_id }
}

output "bot_intent_full_ids" {
  description = "Map of intent names to their full composite IDs"
  value       = { for k, intent in aws_lexv2models_intent.this : k => intent.id }
}