output "frontend_api_url_secret_arn" {
  value = aws_secretsmanager_secret.frontend_api_url.arn
}