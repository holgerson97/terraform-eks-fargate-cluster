resource "aws_vpc" "main" {

    cidr_block = var.vpc-cidr

    tags = {

        Name = "eks-main"

    }

}

resource "aws_subnet" "cluster-subnets" {

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

resource "aws_eks_cluster" "eks-cluster" {

    name     = var.eks-cluster-name
    version  = var.kuberntes.version
    role_arn = ""

    vpc_config {

        subnet_ids         = [ aws_subnet.cluster-subnets.*.id ]
        security_group_ids = [ aws_security_group.default.id ]

    }

    kubernetes_network_config = {
        
        service_ipv4_cidr = var.kubernetes-network-cdir

    }

    depends_on = [

        aws_subent.cluster-subnets,
        aws_internet_gateway.internet-gw,
        aws_security_group.default

    ]

}