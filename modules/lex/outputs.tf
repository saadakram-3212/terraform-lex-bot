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