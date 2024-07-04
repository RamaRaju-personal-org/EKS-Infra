provider "aws" {
  region = "us-east-1"
}

variable vpc_cidr_block {}
variable private_subnet_cidr_blocks {}
variable public_subnet_cidr_blocks {}

data "aws_availability_zones" "azs" {} # quires all the availability zones in the region eu-central-1

module "myapp-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "ram-vpc"
  cidr = var.vpc_cidr_block
  private_subnets = var.private_subnet_cidr_blocks
  public_subnets = var.public_subnet_cidr_blocks
  azs = data.aws_availability_zones.azs.names # deploy to multiple Az's

  enable_nat_gateway = true  # 
  single_nat_gateway = true  # shared nat gateway for all private subnets
  enable_dns_hostnames = true # ex: ec2 gets apublic and private dns names

  tags = {
    "kubernetes.io/cluster/ram-eks-cluster" = "shared" #
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/ram-eks-cluster" = "shared"
    "kubernetes.io/role/elb" = 1 # cloud native loadbalancer for public subnet 
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/ram-eks-cluster" = "shared"
    "kubernetes.io/role/internal-elb" = 1 # loadbalancer for private subnet 
  }
}
