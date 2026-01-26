# ==============================================================================
# SECURELY GENERATE AND STORE PACKER CREDENTIALS
# ==============================================================================
#
# This module generates a strong random password and stores the resulting
# username/password pair in AWS Secrets Manager.
#
# Notes:
# - The secret value is versioned automatically via Secrets Manager.
# - The password is generated at apply time and should not be hardcoded.
# - Consider enabling automatic rotation if this secret is long-lived.
# ==============================================================================

resource "random_password" "generated" {
  # Generate a random password for the Packer user.
  length = 24

  # Use an alphanumeric-only password for broad compatibility.
  special = false
}

resource "aws_secretsmanager_secret" "packer_credentials" {
  # Create the Secrets Manager secret container (metadata + IAM target).
  name = "packer-credentials"
}

resource "aws_secretsmanager_secret_version" "packer_credentials_version" {
  # Store the secret value as a new version on the secret container.
  secret_id = aws_secretsmanager_secret.packer_credentials.id

  # Persist credentials as JSON for easy consumption by scripts and tooling.
  secret_string = jsonencode({
    user     = "packer"
    password = random_password.generated.result
  })
}
