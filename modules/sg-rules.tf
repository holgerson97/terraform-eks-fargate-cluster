# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "eks_sg" {

    description = "Security Group for EKS cluster."

    name        = "eks_sg"
    vpc_id      = aws_vpc.main.id

    tags = {
        Name = "${var.resource_name_tag_prefix}-eks-sg"
    }

    depends_on =  [ aws_vpc.main ]

}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
resource "aws_security_group_rule" "egress" {

    description       = "Allow all egress traffic"

    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = aws_security_group.eks_sg.id
    type              = "egress"

    depends_on = [ aws_security_group.eks_sg ]

}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
resource "aws_security_group_rule" "ingress" {

    description       = "Allow all ingress traffic"

    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = aws_security_group.eks_sg.id
    type              = "ingress"

    depends_on = [ aws_security_group.eks_sg ]

}