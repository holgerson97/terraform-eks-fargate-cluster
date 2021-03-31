# data "aws_eks_cluster" "eks_cluster" {

#     name = var.eks_cluster_name

# }

# data "aws_eks_cluster_auth" "eks_cluster" {

#     name = var.eks_cluster_name
    
# }

# provider "kubernetes" {

#     host                   = data.aws_eks_cluster.eks_cluster.endpoint
#     cluster_ca_certificate = base64decode(data.aws_eks_cluster.example.certificate_authority[0].data)
#     token                  = data.aws_eks_cluster_auth.eks_cluster.token
#     load_config_file       = false

# }

