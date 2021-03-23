resource "aws_security_group" "default" {

    description = "Security Group for EKS cluster."

    name        = "default"
    vpc_id      = aws_vpc.main.id

    tags = {
        Name = "default"
    }

    depends_on =  [ aws_vpc.main ]

}

resource "aws_security_group_rule" "egress" {

    description       = "Allow all egress traffic"

    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = aws_security_group.default.id
    type              = "egress"

    depends_on = [ aws_security_group.default ]

}