data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.devops_interview_eks.name
  depends_on = [aws_eks_cluster.devops_interview_eks]
}

data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.devops_interview_eks.name
  depends_on = [aws_eks_cluster.devops_interview_eks]
}

data "tls_certificate" "oidc" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  depends_on = [aws_eks_cluster.devops_interview_eks]
}

resource "aws_iam_openid_connect_provider" "oidc" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc.certificates[0].sha1_fingerprint]
}

data "aws_iam_policy_document" "irsa_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.oidc.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:sub"
      values   = ["system:serviceaccount:rails-app:rails-app-sa"]
    }
  }
}

resource "aws_iam_role" "irsa" {
  name = "rails-app-irsa"
  assume_role_policy = data.aws_iam_policy_document.irsa_assume_role.json
}

resource "aws_iam_policy" "irsa_policy" {
  name = "rails-app-irsa-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = [
          aws_s3_bucket.app.arn,
          "${aws_s3_bucket.app.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [aws_secretsmanager_secret.db_password02.arn]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "irsa_attach" {
  role       = aws_iam_role.irsa.name
  policy_arn = aws_iam_policy.irsa_policy.arn
}

