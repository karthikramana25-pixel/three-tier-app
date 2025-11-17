variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t3.medium"
}

variable "ssh_pub_key" {
  type        = string
}

variable "ssh_private_key_path" {
  type        = string
}

variable "github_org_or_user" {
  type        = string
}

variable "github_token" {
  type        = string
  sensitive   = true
}
