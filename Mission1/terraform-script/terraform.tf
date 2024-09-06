# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {

  # cloud {
  #   workspaces {
  #     name = "learn-terraform-eks"
  #   }
  # }

  # Specifies the required providers for this configuration
  required_providers {

    # AWS provider configuration
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.47.0"
    }

    # Random provider configuration to generate random values
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.1"
    }

    # TLS provider configuration to generate and manager TLS Certs
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.5"
    }

    # 
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.3.4"
    }
  }

  # Configure the S3 Backend for storing Terraform state files
  backend "s3" {
    bucket  = "terraform-state-v299"
    key     = "test"
    region  = "ap-southeast-1"
    profile = "admin"
  }



  required_version = "~> 1.3"
}



