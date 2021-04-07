output "eks_cluster_general" {

    description = "General cluster information."
  
    value = data.aws_eks_cluster.eks_cluster

}

output "eks_cluster_auth" {

    description = "Cluster information to get access token. Used to connect kubernetes provider."

    value = data.aws_eks_clsuter_auth.eks_cluster
  
}

output "private_subnets" {

    description = "Private subnets allocated to the EKS cluster. This is where your pods go."

    value = toset ([
        for s in aws_subnet.private_subnets : s
    ])

    sensitive = false

}

output "public_subnets" {

    description = "Pulbic subnets used to route traffic to and from your pods."

    value = aws_subnet.public_subnet

    sensitive = false

}

output "fargate_pod_executio_arn" {

    description = "IAM role used to schedule pods. Mainly used to add additional Fargate profiles."

    value = aws_iam_role.fargate_pod_execution.arn

    sensitive = false

}