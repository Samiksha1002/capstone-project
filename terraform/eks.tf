resource "aws_eks_cluster" "eks_cluster" {
  name     = "capstone"
  version = "1.32"  #kubernetes version 1.32 is the latest supported version by AWS EKS as of June 2024, ensuring access to the latest features and improvements in Kubernetes while maintaining compatibility with AWS services.

  role_arn = aws_iam_role.eks_cluster_role.arn
  
  vpc_config {
    subnet_ids = [
      aws_subnet.private_subnet_01.id,
      aws_subnet.private_subnet_02.id,
    ]
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }
  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_role_policy,
  ]

  tags = {
    Name = "eks-cluster"
  }
}
############################################################################
#resource "aws_eks_access_entry" "final_project_access" {
#  cluster_name      = aws_eks_cluster.eks_cluster.name
#  principal_arn     = "arn:aws:iam::821738008755:user/final-project"
#  kubernetes_groups = ["system:masters"]  # gives full admin in Kubernetes
#  type              = "STANDARD"
#}
############################################################################
#terraform-cli-1 user access to EKS cluster
resource "aws_eks_access_entry" "terraform_user" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = "arn:aws:iam::821738008755:user/terraform-cli-1"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "terraform_user_admin" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = "arn:aws:iam::821738008755:user/terraform-cli-1"
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

# root user access to EKS cluster
resource "aws_eks_access_entry" "terraform_root_user" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = "arn:aws:iam::821738008755:root"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "terraform_root_user_admin" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = "arn:aws:iam::821738008755:root"
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

###########################################################################

#eks node group
resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "eks-node-group"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids = [
    aws_subnet.private_subnet_01.id,
    aws_subnet.private_subnet_02.id,
  ]

  #instance configuration

  instance_types = ["t3.large"]
  capacity_type = "ON_DEMAND" 
  ami_type  = "AL2023_x86_64_STANDARD"
  disk_size      = 50

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_worker_role_policy,
    aws_iam_role_policy_attachment.eks_node_cni_policy,
    aws_iam_role_policy_attachment.eks_node_ecr_readonly_policy,
  ]
  tags = {
   Name = "eks-node-group"
  }
}

###################################################
#EKS MANAGED ADD ONS
######################################################
# VPC CNI
resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = aws_eks_cluster.eks_cluster.name
  addon_name                  = "vpc-cni"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_eks_node_group.node_group
  ]
}

# CoreDNS
resource "aws_eks_addon" "coredns" {
  cluster_name                = aws_eks_cluster.eks_cluster.name
  addon_name                  = "coredns"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_eks_node_group.node_group
  ]
}

# kube-proxy
resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = aws_eks_cluster.eks_cluster.name
  addon_name                  = "kube-proxy"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_eks_node_group.node_group
  ]
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name                = aws_eks_cluster.eks_cluster.name
  addon_name                  = "aws-ebs-csi-driver"
  service_account_role_arn    = aws_iam_role.ebs_csi_role.arn
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_iam_role_policy_attachment.ebs_csi_attach
  ]
}

###################################
data "aws_eks_cluster_auth" "eks_cluster" {
  name = aws_eks_cluster.eks_cluster.name
}