#!/bin/bash
# ==============================================================================
# validate.sh — print what you need to try the lab
#
# Both servers are public: the games server answers on HTTP, the Windows
# desktop server on RDP. Both images carry the packer account, whose
# password is in the packer-credentials secret.
# ==============================================================================

set -euo pipefail

export AWS_DEFAULT_REGION="us-east-2"
# AWS_REGION, if set in the caller's shell, overrides AWS_DEFAULT_REGION.
export AWS_REGION="us-east-2"

get_public_dns_by_name_tag() {
  aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=$1" \
              "Name=instance-state-name,Values=running" \
    --query "Reservations[].Instances[].PublicDnsName" \
    --output text | xargs
}

creds=$(aws secretsmanager get-secret-value --secret-id packer-credentials \
  --query SecretString --output text)
packer_user=$(echo "${creds}" | jq -r .user)
packer_password=$(echo "${creds}" | jq -r .password)
games_dns=$(get_public_dns_by_name_tag "games-ec2-instance")
windows_dns=$(get_public_dns_by_name_tag "desktop-ec2-instance")

echo ""
echo "============================================================================"
echo "Packer AMIs - Validation Output"
echo "============================================================================"
echo ""

if [ -n "${games_dns}" ] && [ "${games_dns}" != "None" ]; then
  printf "NOTE: %-22s %s\n" "Games URL:" "http://${games_dns}"
else
  printf "WARN: %-22s %s\n" "Games server:" "not found or not running"
fi

if [ -n "${windows_dns}" ] && [ "${windows_dns}" != "None" ]; then
  printf "NOTE: %-22s %s\n" "Windows server (RDP):" "${windows_dns}"
else
  printf "WARN: %-22s %s\n" "Windows server (RDP):" "not found or not running"
fi
echo ""

printf "NOTE: %-22s %s\n" "Packer user:" "${packer_user}"
printf "NOTE: %-22s %s\n" "Packer password:" "${packer_password}"
echo ""
