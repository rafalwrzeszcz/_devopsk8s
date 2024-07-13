module "eks_ebs_csi_driver" {
  source  = "lablabs/eks-ebs-csi-driver/aws"
  version = "0.1.1"

  cluster_identity_oidc_issuer     = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  cluster_identity_oidc_issuer_arn = aws_iam_openid_connect_provider.oidc.arn
}
