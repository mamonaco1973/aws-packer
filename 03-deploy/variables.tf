############################################
# VARIABLES: DEFINE RESOURCE NAMES
############################################

variable "vpc_name_tag" {
  description = "Name tag of the existing VPC"
  type        = string
  default     = "packer-vpc"
}

variable "subnet_name_tag_1" {
  description = "Name tag of the first public subnet"
  type        = string
  default     = "packer-subnet-1"
}

variable "subnet_name_tag_2" {
  description = "Name tag of the second public subnet"
  type        = string
  default     = "packer-subnet-2"
}

variable "sg_name_http" {
  description = "Name tag of the security group for HTTP"
  type        = string
  default     = "packer-sg-http"
}

variable "sg_name_https" {
  description = "Name tag of the security group for HTTPS"
  type        = string
  default     = "packer-sg-https"
}

variable "sg_name_ssh" {
  description = "Name tag of the security group for SSH"
  type        = string
  default     = "packer-sg-ssh"
}

variable "sg_name_rdp" {
  description = "Name tag of the security group for RDP"
  type        = string
  default     = "packer-sg-rdp"
}

