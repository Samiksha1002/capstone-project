#module "eks" {
#  source  = "terraform-aws-modules/eks/aws"
#  version = "21.15.1"
#
#  name               = "capstone"
#   kubernetes_version = "1.35" #chnge to 1.34 -----impo.
#
#  # Optional: Adds the current caller identity as an administrator via cluster access entry
#  enable_cluster_creator_admin_permissions = true
#
#
#  # security group for worker nodes
#
#  vpc_id = aws_vpc.project_vpc.id
#  subnet_ids = [
#    #aws_subnet.public-subnet-1.id,
#    #aws_subnet.public-subnet-2.id,
#    aws_subnet.private_subnet_01.id, # we are using private subnets for our EKS cluster to enhance security by isolating the worker nodes from direct internet access. This setup allows the worker nodes to communicate with the EKS control plane and other AWS services securely without exposing them to the public internet.
#    aws_subnet.private_subnet_02.id,
#  ]
#
#  endpoint_public_access  = true # Enable public access to the EKS cluster endpoint  , lets us access the cluster from outside the VPC , from our local machine
#  endpoint_private_access = true # Enable private access to the EKS cluster endpoint , allows communication between resources within the VPC and the EKS cluster without exposing the endpoint to the public internet
#
#
#  eks_managed_node_groups = {
#
#    capstone = {
#      #name = "capstone-backend-ng"
#
#      ami_type       = "AL2023_x86_64_STANDARD"
#      instance_types = ["t3.medium"]
#
#      desired_size = var.desired_capacity_on_demand
#      min_size     = var.min_capacity_on_demand
#      max_size     = var.max_capacity_on_demand
#
#      iam_role_additional_policies = {
#      ecr = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
#  
#    }
#    }
#  }
#
#}
#
#