resource "aws_vpc" "main" {

    cidr_block = var.vpc-cidr

    tags = {

        Name = "eks-main"

    }

}

resource "aws_subnet" "cluster_subnets" {

    for_each = var.subnet-cidr

    vpc_id      = aws_vpc.main.id
    cidr_block  = each.value

    tags = {
        
        Name = each.key

    }

    depends_on = [ aws_vpc.main ]

}

resource "aws_internet_gateway" "internet-gw" {

  vpc_id = aws_vpc.main.id

  tags = {

    Name = "eks-main"

  }

    depends_on = [ aws_vpc.main ]

}

resource "aws_eks_cluster" "eks_cluster" {

    name     = var.eks-cluster-name
    version  = var.kubernetes_version
    role_arn = aws_iam_role.default.arn

    vpc_config {

        subnet_ids         = [ for s in aws_subnet.cluster_subnets : s.id ]
        security_group_ids = [ join("", aws_security_group.default.*.id) ]

    }

    kubernetes_network_config {
        
        service_ipv4_cidr = var.kubernetes_network_cidr

    }

    depends_on = [

        aws_subnet.cluster_subnets,
        aws_internet_gateway.internet-gw,
        aws_security_group.default

    ]

}

resource "aws_eks_fargate_profile" "kube-system" {

    cluster_name           = aws_eks_cluster.eks_cluster.name
    fargate_profile_name   = "kube-system"
    pod_execution_role_arn = aws_iam_role.fargate_pod_execution.arn
    subnet_ids             = [ for s in aws_subnet.cluster_subnets : s.id ]

    selector {

        namespace = "kube-system"

    }

    depends_on = [

        aws_eks_cluster.eks_cluster,
        aws_iam_role.fargate_pod_execution

    ]
}