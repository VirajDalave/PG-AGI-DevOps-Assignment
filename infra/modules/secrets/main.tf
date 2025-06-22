resource "aws_secretsmanager_secret" "frontend_api_url" {
  name = "NEXT_PUBLIC_URL"
  description = "API URL used by frontend to connect to backend"
}

resource "aws_secretsmanager_secret_version" "frontend_api_url_value" {
  secret_id = aws_secretsmanager_secret.frontend_api_url.id
  secret_string = jsonencode({
    NEXT_PUBLIC_API_URL = var.frontend_api_url
  })
}

