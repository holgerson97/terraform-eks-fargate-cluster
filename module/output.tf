output "cluster_endpoint" {

    description = "The endpoint of your cluster."

    value = aws_eks_cluster.eks_cluster.endpoint

    sensitive = false

}

output "cluster_name" {

    description = "The name of your cluster. Mainly used to add additional Fargate profiles."

    value = aws_eks_cluster.eks_cluster.name

    sensitive = false

}

output "private_subnets" {

    description = "Private subnets allocated to the EKS cluster. This is where your pods go."

    value = aws_subnet.private_subnets[each.key]

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