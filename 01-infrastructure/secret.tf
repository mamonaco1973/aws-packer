resource "random_password" "generated" {
  length  = 24
  special = false  # Alphanumeric only
}

resource "aws_secretsmanager_secret" "packer_credentials" {
  name = "packer-credentials"
}

resource "aws_secretsmanager_secret_version" "packer_credentials_version" {
  secret_id     = aws_secretsmanager_secret.packer_credentials.id

  secret_string = jsonencode({
    user     = "packer"
    password = random_password.generated.result
  })
}
