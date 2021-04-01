# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster
resource "aws_eks_cluster" "eks_cluster" {

    name     = var.eks_cluster_name
    version  = var.kubernetes_version
    role_arn = aws_iam_role.default.arn

    enabled_cluster_log_types = var.kubernetes_cluster_logs

    vpc_config {

        subnet_ids         = [ for s in aws_subnet.private_subnets : s.id ]
        security_group_ids = [ join("", aws_security_group.eks_sg.*.id) ]

    }

    kubernetes_network_config {
        
        service_ipv4_cidr = var.kubernetes_network_cidr

    }

    tags = {

        Name = "${var.resource_name_tag_prefix}-cloudwatch-group"

    }

    depends_on = [

        aws_subnet.private_subnets,
        aws_internet_gateway.internet_gw,
        aws_security_group.eks_sg,
        aws_cloudwatch_log_group.eks_cluster

    ]

}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group
resource "aws_cloudwatch_log_group" "eks_cluster" {


    name              = "/aws/eks/${var.eks_cluster_name}/cluster"
    retention_in_days = 7

    tags = {

        Name = "${var.resource_name_tag_prefix}-cloudwatch-group"

    }

}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_fargate_profile
resource "aws_eks_fargate_profile" "kube-system" {

    cluster_name           = aws_eks_cluster.eks_cluster.name
    fargate_profile_name   = "kube-system"
    pod_execution_role_arn = aws_iam_role.fargate_pod_execution.arn
    subnet_ids             = [ for s in aws_subnet.private_subnets : s.id ]

    selector {

        namespace = "kube-system"

    }

    tags = {

        Name = "${var.resource_name_tag_prefix}-fp-kube-system"

    }

    depends_on = [

        aws_eks_cluster.eks_cluster,
        aws_iam_role.fargate_pod_execution

    ]
}