resource "aws_ecr_repository" "app" {
  name = "devops-interview-ror-app"
}

resource "aws_s3_bucket" "app" {
  bucket = "devops-interview-app-bucket"
  force_destroy = true
  acl = "private'
}
