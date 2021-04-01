variable "vpc_cidr" {
    
    description = "CIDR of VPC where EKS is going to be deployed."

    type        = string
    default     = "10.10.0.0/16"

    sensitive   = false
}

variable "subnet_cidr" {

    description = "CIDR for subnets, that are going to be used by EKS." 
    
    type        = map
    default     = { 
                    "subnet-first"  = "10.10.1.0/24",
                    "subnet-second" = "10.10.2.0/24", 
                    "subnet-third"  = "10.10.3.0/24"
                }

    sensitive   = false
}

variable "eks_cluster_name" {

    description = "Name of the EKS cluster, that is going to be deployed."

    type        = string
    default     = "EKS-Cluster"

    sensitive   = false

}

variable "resource_name_tag_prefix" {

    description = "Default prefix for all resource names. Will be prefix-resource-type."

    type        = string
    default     = "eks-cluster"

    sensitive   = false

}

variable "kubernetes_version" {

    description = "Version of Kubernetes (kubelet), that is going to be deploed."

    type        = string
    default     = "1.19"

    sensitive   = false

}

variable "kubernetes_network_cidr" {

    description = "Pod CIDR for Kubernetes cluster."

    type        = string
    default     = "172.16.0.0/16"

    sensitive   = false
    
}

variable "kubernetes_cluster_logs" {

    description = "List of control pane components, that need to have active logging."

    type        = list(string)
    default     = [ "api", "audit", "authenticator", "controllerManager", "scheduler" ]

    sensitive   = false

}

variable "permissions_boundary" {

    description = "ARN of the policy that is used to set the permissions boundary for the role."

    type        = string
    default     = null

    sensitive   = false

}

variable "eks_cluster_iam_role_name" {

    description = "Name of EKS cluster IAM role."

    type        = string
    default     = "eks_cluster"

    sensitive   = false

}

variable "fargate_iam_role_name" {

    description = "Name of fargate pod execution IAM role."

    type        = string
    default     = "fargate_pod_execution_role"

    sensitive   = false

}