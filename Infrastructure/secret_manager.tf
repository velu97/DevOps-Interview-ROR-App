resource "aws_secretsmanager_secret" "db_password02" {
  name = "devops-interview-db-password02"
}

resource "aws_secretsmanager_secret_version" "db_password_value02" {
  secret_id     = aws_secretsmanager_secret.db_password02.id
  secret_string = "changeMe123!" # i have used this for demo. Need to use in secure way in production
}
