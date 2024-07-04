
# 🌟 AWS EKS Cluster with Terraform 🌟

This repository provides a comprehensive Terraform configuration to set up an Amazon Elastic Kubernetes Service (EKS) cluster in AWS. The configuration includes VPC setup, EKS cluster creation, and managed node groups, enabling a robust and scalable Kubernetes environment.

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Variables](#variables)
- [Outputs](#outputs)
- [Notes](#notes)
- [Tips](#tips)
- [Important](#important)
- [License](#license)

## 🌟 Overview

This Terraform module deploys an EKS cluster in AWS, including:

- A VPC with public and private subnets across multiple Availability Zones
- An EKS cluster with managed node groups
- NAT Gateway for internet access from private subnets
- Tags for Kubernetes and load balancers

## 🛠️ Prerequisites

- Terraform 0.12 or later
- AWS CLI configured with appropriate credentials
- S3 bucket for storing Terraform state

## 🚀 Usage

To use this configuration, follow these steps:

1. **Clone the repository**:
   \`\`\`sh
   git clone https://github.com/yourusername/your-repo-name.git
   cd your-repo-name
   \`\`\`

2. **Initialize Terraform**:
   \`\`\`sh
   terraform init
   \`\`\`

3. **Create a \`terraform.tfvars\` file**:
   \`\`\`hcl
   vpc_cidr_block = "10.0.0.0/16"
   private_subnet_cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24"]
   public_subnet_cidr_blocks = ["10.0.101.0/24", "10.0.102.0/24"]
   \`\`\`

4. **Apply the Terraform configuration**:
   \`\`\`sh
   terraform apply
   \`\`\`

## 🔧 Variables

- \`vpc_cidr_block\`: CIDR block for the VPC
- \`private_subnet_cidr_blocks\`: List of CIDR blocks for private subnets
- \`public_subnet_cidr_blocks\`: List of CIDR blocks for public subnets

## 📦 Outputs

The module provides the following outputs:

- \`eks_cluster_id\`: The ID of the EKS cluster
- \`eks_cluster_endpoint\`: The endpoint for the EKS cluster
- \`eks_cluster_version\`: The Kubernetes version of the EKS cluster

## 📝 Notes

- Ensure that your AWS credentials have the necessary permissions to create and manage the resources defined in this configuration.
- Adjust the \`desired_size\`, \`min_size\`, and \`max_size\` parameters in the \`eks_managed_node_groups\` configuration according to your workload requirements.
- The \`single_nat_gateway\` is set to true for cost savings. For higher availability, consider setting up multiple NAT Gateways across different Availability Zones.

## 💡 Tips

- Use the \`terraform plan\` command before applying changes to see a preview of the actions Terraform will take.
- Regularly update the Terraform AWS provider to benefit from the latest features and bug fixes.
- Tag your resources appropriately for better management and cost allocation.

## ⚠️ Important

- **Security**: Ensure that the EKS cluster and associated resources are secured according to best practices. Consider using IAM roles, security groups, and network ACLs.
- **Cost**: Be aware of the costs associated with running an EKS cluster, including the EC2 instances for worker nodes, NAT Gateway charges, and data transfer costs.
- **Region**: The configuration specifies the \`us-east-1\` region. Modify this as needed to deploy resources in your desired AWS region.

---

### Detailed Terraform Configuration

Below is the detailed configuration for setting up an EKS cluster using Terraform.

#### EKS Module Configuration

\`\`\`hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.17.2"

  cluster_name                    = "ram-eks-cluster"
  cluster_version                 = "1.27"
  cluster_endpoint_public_access  = true

  subnet_ids = module.myapp-vpc.private_subnets
  vpc_id     = module.myapp-vpc.vpc_id

  tags = {
    environment = "development"
    application = "ram"
  }

  eks_managed_node_groups = {
    dev = {
      min_size     = 1
      max_size     = 3
      desired_size = 3
      instance_types = ["t2.small"]
    }
  }
}
\`\`\`

- **cluster_name**: Name of the EKS cluster.
- **cluster_version**: Kubernetes version for the EKS cluster.
- **cluster_endpoint_public_access**: Whether the EKS cluster endpoint is publicly accessible.
- **subnet_ids**: List of private subnet IDs where worker nodes will be launched.
- **vpc_id**: ID of the VPC.
- **tags**: Tags applied to EKS resources.
- **eks_managed_node_groups**: Configuration for managed node groups. Here, it specifies the minimum, maximum, and desired size for the \`dev\` node group with \`t2.small\` instances.

#### Terraform Provider and Backend Configuration

\`\`\`hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.20.1"
    }
  }
}

terraform {
  required_version = ">= 0.12"
  backend "s3" {
    bucket = "your-bucket-name"  # Create this bucket first
    key    = "path/to/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}
\`\`\`

- **required_providers**: Specifies the AWS provider with its version.
- **required_version**: Minimum required version of Terraform.
- **backend "s3"**: Configuration for storing Terraform state in an S3 bucket.
- **provider "aws"**: AWS provider configuration with the region set to \`us-east-1\`.

#### VPC Module Configuration

\`\`\`hcl
variable vpc_cidr_block {}
variable private_subnet_cidr_blocks {}
variable public_subnet_cidr_blocks {}

data "aws_availability_zones" "azs" {}  # Queries all the availability zones in the region

module "myapp-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name                 = "ram-vpc"
  cidr                 = var.vpc_cidr_block
  private_subnets      = var.private_subnet_cidr_blocks
  public_subnets       = var.public_subnet_cidr_blocks
  azs                  = data.aws_availability_zones.azs.names
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/ram-eks-cluster" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/ram-eks-cluster" = "shared"
    "kubernetes.io/role/elb"               = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/ram-eks-cluster" = "shared"
    "kubernetes.io/role/internal-elb"       = 1
  }
}
\`\`\`

- **vpc_cidr_block**: CIDR block for the VPC.
- **private_subnet_cidr_blocks**: List of CIDR blocks for private subnets.
- **public_subnet_cidr_blocks**: List of CIDR blocks for public subnets.
- **aws_availability_zones**: Data source to get the names of availability zones in the region.
- **module "myapp-vpc"**: VPC module configuration.
  - **name**: Name of the VPC.
  - **cidr**: CIDR block for the VPC.
  - **private_subnets**: List of private subnets.
  - **public_subnets**: List of public subnets.
  - **azs**: Availability zones for subnets.
  - **enable_nat_gateway**: Enables NAT Gateway.
  - **single_nat_gateway**: Uses a single NAT Gateway for all private subnets.
  - **enable_dns_hostnames**: Enables DNS hostnames in the VPC.
  - **tags**: Tags for the VPC resources.
  - **public_subnet_tags**: Tags for public subnets.
  - **private_subnet_tags**: Tags for private subnets.

Feel free to customize the configurations according to your requirements. Happy Terraforming! 🌍🚀
