# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "assume_role_eks" {

    statement {
        effect  = "Allow"
        actions = ["sts:AssumeRole"]

        principals {
            type        = "Service"
            identifiers = ["eks.amazonaws.com"]
        }
    }

}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "default" {

    description          = "IAM role to manage the cluster and deploy fargate pods."

    name                 = var.eks_cluster_iam_role_name
    assume_role_policy   = data.aws_iam_policy_document.assume_role_eks.json
    permissions_boundary = var.permissions_boundary

}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment
resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.default.name

  depends_on = [ aws_iam_role.default ]

}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "assume_role_pod_execution" {

    statement {
        effect  = "Allow"
        actions = ["sts:AssumeRole"]

        principals {
            type        = "Service"
            identifiers = ["eks-fargate-pods.amazonaws.com"]
        }
    }

}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "fargate_pod_execution" {

    description          = "IAM role to allow fargate profiles to run pods inside EKS cluster."

    name                 = var.fargate_iam_role_name
    assume_role_policy   = data.aws_iam_policy_document.assume_role_pod_execution.json
    permissions_boundary = var.permissions_boundary

}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment
resource "aws_iam_role_policy_attachment" "example-AmazonEKSFargatePodExecutionRolePolicy" {

    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
    role       = aws_iam_role.fargate_pod_execution.name

    depends_on = [ aws_iam_role.fargate_pod_execution ]
}