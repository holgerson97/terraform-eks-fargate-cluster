data "aws_iam_policy_document" "assume_role" {

    statement {
        effect  = "Allow"
        actions = ["sts:AssumeRole"]

        principals {
            type        = "Service"
            identifiers = ["eks.amazonaws.com"]
        }
    }

}

resource "aws_iam_role" "default" {

    description          = "IAM role to manage the cluster and deploy fargate pods."

    name                 = "eks-cluster"
    assume_role_policy   = data.aws_iam_policy_document.assume_role.json
    permissions_boundary = var.permissions-boundary

    depends_on = [ aws_iam_policy_document.assume_role ]

}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.default

  depends_on = [ aws_iam_role.default ]

}