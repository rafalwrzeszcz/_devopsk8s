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

resource "aws_eks_node_group" "master" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = module.vpc.private_subnets

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_worker_policy,
    aws_iam_role_policy_attachment.node_cni_policy,
    aws_iam_role_policy_attachment.node_ecr_policy,
  ]
}
