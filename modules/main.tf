resource "aws_vpc" "main" {

    cidr_block           = var.vpc_cidr
    enable_dns_hostnames = true

    tags = {

        Name = "eks-main"
        "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"

    }

}
##########################################################################################################################################################
resource "aws_subnet" "public_subnet" {
  
    vpc_id                  = aws_vpc.main.id
    cidr_block              = "10.10.5.0/24"
    map_public_ip_on_launch = true

    tags = {

        Name = "public_subnet"
        state  = "public"
        "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
        "kubernetes.io/role/elb" = 1

    }

}

resource "aws_eip" "public_ip" {
  
    vpc = true

}

resource "aws_nat_gateway" "test" {

    allocation_id = aws_eip.public_ip.id
    subnet_id     = aws_subnet.public_subnet.id
  
}

resource "aws_route_table" "internet_route" {

  vpc_id = aws_vpc.main.id

  route {

    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gw.id

  }

  tags = {

    Name = "main"
    state = "public"

  }
  
}

resource "aws_route_table" "nat_route" {

  vpc_id = aws_vpc.main.id

  route {

    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.test.id
    
  }

  tags = {

    Name = "main"
    state = "public"

  }
  
}

resource "aws_route_table_association" "public" {

  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.internet_route.id

}

resource "aws_route_table_association" "private" {

    for_each = var.subnet_cidr

    subnet_id      = aws_subnet.cluster_subnets[each.key].id
    route_table_id = aws_route_table.nat_route.id

    depends_on = [ aws_route_table.nat_route ]

}

##########################################################################################################################################################
resource "aws_subnet" "cluster_subnets" {

    for_each = var.subnet_cidr

    vpc_id                  = aws_vpc.main.id
    cidr_block              = each.value
    map_public_ip_on_launch = false


    tags = {
        "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
        "kubernetes.io/role/internal-elb" = 1
        Name = each.key
        state = "private"
    }

    depends_on = [ aws_vpc.main ]

}

resource "aws_internet_gateway" "internet_gw" {

  vpc_id = aws_vpc.main.id

  tags = {

    Name = "eks-cluster-inet-gw"

  }

    depends_on = [ aws_vpc.main ]

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