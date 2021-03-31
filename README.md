# Terraform EKS Fargate Cluster

This module provides a fully functional EKS Fargate only cluster.

To see which variables are worth changing look at the "Variables" section.

After the deployment, you need to edit some settings inside your cluster manually since there are some configurations, that can't be changed with Terraform or aren't supported by this module at the time. You can see instructions at the "Deployed? What now?".  
&nbsp;
# Getting started

You can use this deployment without changing any variables. The most common is to change the VPC/Subnet CIDRs nor add/remove subnets. Just copy and paste this snippet to get started.  
&nbsp;
## Basic usage:
```hcl
module "eks-fargate" {
    
    source = "github.com/holgerson97/terraform-eks-fargate-cluster//terraform-e113-vpn-s2s"
    
}
```
&nbsp;
## Advanced usage:
```hcl
module "eks-fargate" {
    
    source = "github.com/holgerson97/terraform-eks-fargate-cluster//terraform-e113-vpn-s2s"

    eks_cluster_name   = "eks-cluster-stage"
    kubernetes_version = "1.19"

    vpc_cidr           = "10.10.0.0/16"
    public_subnet      = "10.10.1.0/24"
    private_subnets    = {
                          "subnet-first"  = "10.10.2.0/24",
                          "subnet-second" = "10.10.3.0/24",
                          "subnet-third"  = "10.10.4.0/24"
                         }

}
```
&nbsp;
# Variables
| Variable                 |  Type  | Description                                                                 |
| :----------------------- | :----: | :-------------------------------------------------------------------------- |
| vpc_cidr                 | string | CIDR of VPC where EKS is going to be deployed.                              |
| private_subnets          | map    | Private subnets where pods are going to be deployed.                        |
| eks_cluster_name         | string | Name of the EKS cluster, that is going to be deployed.                      |
| resource_name_tag_prefix | string | Default prefix for all resource names. Will be prefix-resource-type.        |
| kubernetes_version       | string | Version of Kubernetes (kubelet), that is going to be deploed.               |
| kubernetes_network_cidr  | string | Pod CIDR for Kubernetes cluster.                                            |
| kubernetes_cluster_logs  | string | List of control pane components, that need to have active logging.          |
| permissions_boundary     | string | ARN of the policy that is used to set the permissions boundary for the role.|
| eks_cluster_iam_role_name| string | Name of EKS cluster IAM role.                                               |
| fargate_iam_role_name    | string | Name of fargate pod execution IAM role.                                     |
&nbsp;
# Deployed? What now?
## Getting access to cluster
Since Terraform uses an IAM user to authenticate with AWS CDK, the Kubernetes Cluster-Administrator role is only applied to the IAM user ARN. To change this you need to log in with the user's credentials at AWS CLI. Then you need to update your kubeconfig file to get access to the cluster.  
&nbsp;
```
aws eks update-kubeconfig --name <cluster-name>
```
&nbsp;

**NOTE:** You may also need to add the region in which you deployed your EKS cluster. This depends on the default region of your AWC CLI profile (--region). If you added the IAM user credentials to a new user you may also need to specify the profile (--profile).
&nbsp;
After that, you can change the aws-auth config map and add your roles, groups, and users. Just run the following command.  
&nbsp;
```
kubectl edit configmap -n kube-system aws-auth
```
Reference: https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html
&nbsp;
## Updating CoreDNS deployment to run on Fargate
By default, the CoreDNS deployment is configured to run on worker nodes. Since we don't attach any worker node pools to the EKS cluster you need to patch the deployment. Currently, it's not possible to patch deployment via the Kubernetes Terraform provider, so you need to do it by hand.

&nbsp;
```
kubectl patch deployment coredns \
            -n kube-system \
            --type json \
            -p='[{"op": "remove", "path": "/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type"}]'
```
```
kubectl rollout restart -n kube-system deployment coredns
```
Reference: https://docs.aws.amazon.com/eks/latest/userguide/fargate-getting-started.html