output "db_endpoint" {
  value = module.db.db_instance_endpoint
}

output "s3_bucket" {
  value = aws_s3_bucket.app.bucket
}

output "ecr_repo_url" {
  value = aws_ecr_repository.app.repository_url
}

output "db_password_secret_arn" {
  value = aws_secretsmanager_secret.db_password.arn
}

output "irsa_role_arn" {
  value = aws_iam_role.irsa.arn
}
