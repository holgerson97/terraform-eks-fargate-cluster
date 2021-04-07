variable "openid_enabled" {

    description = "Enable the OpenID Connect provider for Kubernetes."
    
    type        = bool
    default     = false
    
    sensitive   = false
  
}

variable "openid_url" {

    description = "OpenID url where users login."
    
    type        = string
    default     = null
    
    sensitive   = false

}

variable "openid_client_id" {

    description = "Provider specific OpenID application specifier."
    
    type        = list(string)
    default     = null
    
    sensitive   = false

}

variable "openid_thumbprint" {

    description = "Provider specific OpenID server certificate thumbprints."
    
    type        = list(string)
    default     = null
    
    sensitive   = false

}

data "tls_certificate" "openid_tls" {
  
    url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer

}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider
resource "aws_iam_openid_connect_provider" "main" {

    count           = var.openid_enabled == true ? 1 : 0

    client_id_list  = var.openid_client_id
    url             = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer

    thumbprint_list = [data.tls_certificate.openid_tls.certificates[0].sha1_fingerprint]
  
}