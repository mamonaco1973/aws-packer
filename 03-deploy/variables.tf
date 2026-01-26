# ==============================================================================
# VARIABLES: RESOURCE NAME TAG LOOKUPS
# ==============================================================================
#
# These variables define the Name tag values used to discover existing AWS
# resources via Terraform data sources.
#
# This approach avoids hardcoding resource IDs and allows the configuration
# to integrate cleanly with shared or pre-existing infrastructure.
# ==============================================================================

variable "vpc_name_tag" {
  # Name tag of the target VPC to be discovered.
  description = "Name tag of the existing VPC"
  type        = string
  default     = "packer-vpc"
}

variable "subnet_name_tag_1" {
  # Name tag of the first public subnet used for instance placement.
  description = "Name tag of the first public subnet"
  type        = string
  default     = "packer-subnet-1"
}

variable "subnet_name_tag_2" {
  # Name tag of the second public subnet used for instance placement.
  description = "Name tag of the second public subnet"
  type        = string
  default     = "packer-subnet-2"
}

variable "sg_name_http" {
  # Name tag of the security group allowing inbound HTTP traffic.
  description = "Name tag of the security group for HTTP"
  type        = string
  default     = "packer-sg-http"
}

variable "sg_name_https" {
  # Name tag of the security group allowing inbound HTTPS traffic.
  description = "Name tag of the security group for HTTPS"
  type        = string
  default     = "packer-sg-https"
}

variable "sg_name_ssh" {
  # Name tag of the security group allowing inbound SSH access.
  description = "Name tag of the security group for SSH"
  type        = string
  default     = "packer-sg-ssh"
}

variable "sg_name_rdp" {
  # Name tag of the security group allowing inbound RDP access.
  description = "Name tag of the security group for RDP"
  type        = string
  default     = "packer-sg-rdp"
}
