data "aws_eks_cluster" "eks_clsuter" {

    name = aws_eks_cluster.eks_cluster.name
  
}

data "aws_eks_clsuter_auth" "eks_cluster" {

    name = aws_eks_cluster.eks_cluster.name

}