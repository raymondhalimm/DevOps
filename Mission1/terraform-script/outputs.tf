# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Output the EKS Cluster control plane endpoint
output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

# Output the security group ID attached to EKS cluster control plan
output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

# Output AWS Region being used
output "region" {
  description = "AWS region"
  value       = var.region
}

# Output name of Kubernetes Cluster
output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}

# Output RDS instance hostname
output "rds_hostname" {
  description = "RDS instance hostname"
  value       = aws_db_instance.education.address
  sensitive   = false
}

# Output RDS instance port
output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.education.port
  sensitive   = false
}

# Output RDS instance username
output "rds_username" {
  description = "RDS instance root username"
  value       = aws_db_instance.education.username
  sensitive   = false
}