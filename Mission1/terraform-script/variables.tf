# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Define AWS Region as variable
variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

# Define a senstive variable for RDS Database root user password
variable "db_password" {
  description = "RDS root user password"
  sensitive   = true
}
