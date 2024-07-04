module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.17.2"

  cluster_name = "ram-eks-cluster"
  cluster_version = "1.27"
  cluster_endpoint_public_access  = true # api server is publicly accessbile for kubectl

  subnet_ids = module.myapp-vpc.private_subnets # our worker nodes will be present in private subnet
  vpc_id = module.myapp-vpc.vpc_id

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
