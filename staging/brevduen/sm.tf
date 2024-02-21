resource "aws_secretsmanager_secret" "email_token" {
  name = "brevduen-staging/email-token"
}

data "aws_secretsmanager_secret_version" "email_token" {
  secret_id = aws_secretsmanager_secret.email_token.id
}
