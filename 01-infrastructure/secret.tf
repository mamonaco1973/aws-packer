############################################
# SECURELY GENERATE AND STORE CREDENTIALS FOR PACKER
############################################

# Generate a secure random alphanumeric password
resource "random_password" "generated" {
  length  = 24         # Total password length: 24 characters
  special = false      # Exclude special characters (alphanumeric only for compatibility)
}

# Define a new Secrets Manager secret to store Packer credentials
resource "aws_secretsmanager_secret" "packer_credentials" {
  name = "packer-credentials"   # Logical name for the secret in AWS Secrets Manager
}

# Store the actual credential values in the secret (versioned)
resource "aws_secretsmanager_secret_version" "packer_credentials_version" {
  secret_id = aws_secretsmanager_secret.packer_credentials.id   # Reference the previously created secret

  # Encode credentials as a JSON string and store as the secret value
  secret_string = jsonencode({
    user     = "packer"                          # Static username for the Packer user
    password = random_password.generated.result  # Dynamic, securely generated password
  })
}
