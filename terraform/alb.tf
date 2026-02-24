resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.7.2"

  values = [
    yamlencode({
      clusterName = aws_eks_cluster.eks_cluster.name
      serviceAccount = {
        create      = true
        name        = "aws-load-balancer-controller"
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.alb_irsa_role.arn
        }
      }
      vpcId  = aws_vpc.project_vpc.id      
      region = "ap-south-1"         
    })
  ]

  depends_on = [
    aws_eks_access_entry.terraform_user,
    aws_eks_access_policy_association.terraform_user_admin,
    aws_iam_role.alb_irsa_role,
    aws_iam_role_policy_attachment.alb_attach,
    aws_iam_openid_connect_provider.eks_oidc
  ]
}