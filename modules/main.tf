resource "aws_vpc" "main" {

    cidr_block = var.vpc_cidr

    tags = {

        Name = "eks-main"

    }

}

resource "aws_subnet" "cluster_subnets" {

    for_each = var.subnet_cidr

    vpc_id                  = aws_vpc.main.id
    cidr_block              = each.value
    map_public_ip_on_launch = false


    tags = {
        
        Name = each.key

    }

    depends_on = [ aws_vpc.main ]

}

resource "aws_internet_gateway" "internet_gw" {

  vpc_id = aws_vpc.main.id

  tags = {

    Name = "eks-main"

  }

    depends_on = [ aws_vpc.main ]

}

resource "aws_eip" "nat_eip" {

    count = length(var.subnet_cidr)

    vpc = true

    tags = {

        Name = "eks-cluster-eip-${count.index}"

    }

    depends_on = [ aws_vpc.main ]

}

resource "aws_nat_gateway" "nat_gw" {

    for_each = aws_subnet.cluster_subnets

    allocation_id = aws_eip.nat_eip[index(keys(aws_subnet.cluster_subnets), each.key)].id
    subnet_id     = each.value.id

    tags = {

        Name = "eks-cluster-nat-gw-${each.key}"

    }

    depends_on = [ 
                    aws_eip.nat_eip,
                    aws_internet_gateway.internet_gw
                 ]

}

resource "aws_eks_cluster" "eks_cluster" {

    name     = var.eks_cluster_name
    version  = var.kubernetes_version
    role_arn = aws_iam_role.default.arn

    enabled_cluster_log_types = var.kubernetes_cluster_logs

    vpc_config {

        subnet_ids         = [ for s in aws_subnet.cluster_subnets : s.id ]
        security_group_ids = [ join("", aws_security_group.eks_sg.*.id) ]

    }

    kubernetes_network_config {
        
        service_ipv4_cidr = var.kubernetes_network_cidr

    }

    depends_on = [

        aws_subnet.cluster_subnets,
        aws_internet_gateway.internet_gw,
        aws_security_group.eks_sg,
        aws_cloudwatch_log_group.eks_cluster

    ]

}

resource "aws_cloudwatch_log_group" "eks_cluster" {


  name              = "/aws/eks/${var.eks_cluster_name}/cluster"
  retention_in_days = 7

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