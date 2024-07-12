data "tls_certificate" "oidc" {
  url = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc.certificates[0].sha1_fingerprint]
  url             = data.tls_certificate.oidc.url
}

module "eks_ebs_csi_driver" {
  source  = "lablabs/eks-ebs-csi-driver/aws"
  version = "0.1.1"

  cluster_identity_oidc_issuer = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  cluster_identity_oidc_issuer_arn = aws_iam_openid_connect_provider.oidc.arn
}
