resource "aws_eks_cluster" "cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster_role.arn

  vpc_config {
    subnet_ids = module.vpc.private_subnets
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_default_policy,
  ]
}

resource "aws_eks_fargate_profile" "fargate" {
  cluster_name           = aws_eks_cluster.cluster.name
  fargate_profile_name   = "default"
  pod_execution_role_arn = aws_iam_role.fargate_role.arn
  subnet_ids             = module.vpc.private_subnets

  selector {
    namespace = "default"
  }
}
