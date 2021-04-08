variable "openid_enabled" {

    description = "Enable the OpenID Connect provider for Kubernetes."
    
    type        = bool
    default     = true
    
    sensitive   = false
  
}

# https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/tls_certificate
data "tls_certificate" "openid_tls" {
  
    url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer

}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider
resource "aws_iam_openid_connect_provider" "main" {

    count           = var.openid_enabled == true ? 1 : 0

    client_id_list  = [ "sts.amazonaws.com" ]
    thumbprint_list = [ data.tls_certificate.openid_tls.certificates[0].sha1_fingerprint ]
    url             = join("", aws_eks_cluster.eks_cluster.*.identity.0.oidc.0.issuer)

}