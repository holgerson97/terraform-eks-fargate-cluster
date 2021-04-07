data "aws_eks_cluster" "eks_cluster" {

    name = aws_eks_cluster.eks_cluster.name
  
}

data "aws_eks_cluster_auth" "eks_cluster" {

    name = aws_eks_cluster.eks_cluster.name

}