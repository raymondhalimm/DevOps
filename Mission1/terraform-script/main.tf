# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# AWS Provider configuration
provider "aws" {
  region  = var.region
  profile = "admin"
}

# Kubernetes provider configuration
provider "kubernetes" {
  config_path = "~/.kube/config" # Adjust the path to your kubeconfig
}

# Data block to filter out unsupported local zones for managed node groups
data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# Local values for cluster name generation
locals {
  cluster_name = "education-eks-${random_string.suffix.result}"
}

# Resource for generating random string suffix
resource "random_string" "suffix" {
  length  = 8
  special = false
}

# Module for creating VPC using terraform-aws-modules VPC module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws" # VPC Module source
  version = "5.8.1"

  name = "education-vpc"

  cidr = "10.0.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3) # Use the first 3 availbility zones

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway   = true # Enable NAT gateway
  single_nat_gateway   = true # Use a single NAT gateway
  enable_dns_hostnames = true # Enable DNS hostnames in the VPC
  enable_dns_support   = true # Enable DNS resolution support in the VPC

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

# Resource or AWS RDS Subnet group, using public subnets from VPC module
resource "aws_db_subnet_group" "education" {
  name       = "education-subnet"
  subnet_ids = module.vpc.public_subnets

  tags = {
    Name = "Education"
  }
}

# AWS security group resource for AWS RDS
resource "aws_security_group" "rds" {
  name   = "education_rds"
  vpc_id = module.vpc.vpc_id # Attach to VPC created by VPC module

  # Ingress rules for allowing PostgreSQL traffic (port 5432)
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rules for PostgreSQL traffic
  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "education_rds"
  }
}

# AWS RDS parameter group resource for PostgreSQL Setting
resource "aws_db_parameter_group" "education" {
  name   = "education"
  family = "postgres14"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}

# AWS RDS instance resource configuration
resource "aws_db_instance" "education" {
  identifier             = "education"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "14.13"
  username               = "raymondhalimm"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.education.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.education.name
  publicly_accessible    = true
  skip_final_snapshot    = true
}

# Kubernetes secret for storing RDS Credentials
resource "kubernetes_secret" "db_credentials" {
  metadata {
    name      = "db-credentials"
    namespace = "default"
  }

  data = {
    username = aws_db_instance.education.username
    password = var.db_password
    host     = aws_db_instance.education.address
    port     = aws_db_instance.education.port
    url      = "postgresql://${aws_db_instance.education.username}:${var.db_password}@${aws_db_instance.education.address}:${aws_db_instance.education.port}/postgres"
  }

  type = "Opaque"

  # Ensure kubeconfig has been updated
  depends_on = [null_resource.update_kubeconfig]
}

# Resource to automatically update kubeconfig after the EKS cluster is created
resource "null_resource" "update_kubeconfig" {

  # Ensure this runs after the EKS module is created
  depends_on = [module.eks]

  provisioner "local-exec" {
    command = "aws --profile admin eks --region ${var.region} update-kubeconfig --name ${module.eks.cluster_name}"
  }
}

# Module for creating EKS cluster and its node groups
module "eks" {
  source  = "terraform-aws-modules/eks/aws" # Source for EKS Module
  version = "20.8.5"

  cluster_name    = local.cluster_name
  cluster_version = "1.29"

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    aws-ebs-csi-driver = {
      service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Default configurations for managed node groups
  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

  }

  # Define managed node groups
  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 4
      desired_size = 3
    }

    two = {
      name = "node-group-2"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }
  }
}


# https://aws.amazon.com/blogs/containers/amazon-ebs-csi-driver-is-now-generally-available-in-amazon-eks-add-ons/ 
# Data block for retrieving the Amazon EBS CSI Driver IAM policy
data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# Module for setting up IAM roles with OIDC for the EBS CSI driver
module "irsa-ebs-csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.39.0"

  create_role                   = true
  role_name                     = "AmazonEKSTFEBSCSIRole-${module.eks.cluster_name}"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}
