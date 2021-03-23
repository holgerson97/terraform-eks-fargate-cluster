variable "vpc-cidr" {
    description = "CIDR of VPC where EKS is going to be deployed."

    type        = string
    default     = "10.10.0.0/16"

    sensitive   = false
}

variable "subnet-cidr" {
    description = "CIDR for subnets, that are going to be used by EKS." 
    
    type        = map
    default     = { 
                    "subnet-first"  = "10.10.1.0/24",
                    "subnet-second" = "10.10.2.0/24", 
                    "subnet-third"  = "10.10.3.0/24"
                }

    sensitive   = false
}

variable "eks-cluster-name" {

    description = "Name of the EKS cluster, that is going to be deployed."

    type        = string
    default     = "EKS-Cluster"

    sensitive   = false


}

variable "kubernetes-version" {

    description = "Version of Kubernetes (kubelet), that is going to be deploed."

    type        = string
    default     = "1.19"

    sensitive   = false

}

variable "kubernetes-network-cidr" {

    description = "Pod CIDR for Kubernetes cluster."

    type        = string
    default     = "172.16.0.0/16"

    sensitive   = false
    
}

variable "permissions-boundary" {

    description = "ARN of the policy that is used to set the permissions boundary for the role."

    type        = string
    default     = null

    sensitive   = false

}
