# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "main" {

    cidr_block           = var.vpc_cidr

    tags = {

        Name = "${var.resource_name_tag_prefix}-vpc-main"
        "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"

    }

}

################################# Public Subnet Configuration #################################

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "internet_gw" {

  vpc_id = aws_vpc.main.id

  tags = {

    Name = "${var.resource_name_tag_prefix}-inet-gw"

  }

    depends_on = [ aws_vpc.main ]

}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet
resource "aws_subnet" "public_subnet" {
  
    vpc_id                  = aws_vpc.main.id
    cidr_block              = "10.10.5.0/24"
    map_public_ip_on_launch = true

    tags = {

        Name = "${var.resource_name_tag_prefix}-public-subnet"
        "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
        "kubernetes.io/role/elb" = 1

    }

    depends_on = [ aws_vpc.main ]

}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip
resource "aws_eip" "public_ip" {
  
    vpc = true

    tags = {

        Name = "${var.resource_name_tag_prefix}-public-eip"

    }

    depends_on = [ aws_vpc.main ]

}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway
resource "aws_nat_gateway" "nat_gw" {

    allocation_id = aws_eip.public_ip.id
    subnet_id     = aws_subnet.public_subnet.id

    tags = {

        Name = "${var.resource_name_tag_prefix}-nat-gw"

    }

    depends_on = [ 
                    aws_vpc.main,
                    aws_subnet.public_subnet
                 ]
  
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
resource "aws_route_table" "internet_route" {

    vpc_id = aws_vpc.main.id

    route {

        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internet_gw.id

    }

    tags = {

        Name = "${var.resource_name_tag_prefix}-internet-route"

    }
  
    depends_on = [ 
                    aws_vpc.main,
                    aws_subnet.public_subnet
                 ]

}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/main_route_table_association
resource "aws_route_table_association" "internet_route_table" {

    subnet_id      = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.internet_route.id

    depends_on = [ aws_route_table.internet_route ]

}

################################# Private Subnet Configuration ################################

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet
resource "aws_subnet" "cluster_subnets" {

    for_each = var.subnet_cidr

    vpc_id                  = aws_vpc.main.id
    cidr_block              = each.value
    map_public_ip_on_launch = false


    tags = {
        "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
        "kubernetes.io/role/internal-elb" = 1
        Name = "${var.resource_name_tag_prefix}-${each.key}"
    }

    depends_on = [ aws_vpc.main ]

}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
resource "aws_route_table" "nat_route" {

    vpc_id = aws_vpc.main.id

    route {

        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.nat_gw.id
        
    }

    tags = {

        Name = "${var.resource_name_tag_prefix}-nat-route"

    }
    
    depends_on = [ 
                    aws_vpc.main,
                    aws_subnet.cluster_subnets
                 ]
  
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/main_route_table_association
resource "aws_route_table_association" "nat_route_table" {

    for_each = var.subnet_cidr

    subnet_id      = aws_subnet.cluster_subnets[each.key].id
    route_table_id = aws_route_table.nat_route.id

    depends_on = [ aws_route_table.nat_route ]

}