VPC ->  provisioned to give a network space to work in . along with it we have different subnets in different zones - public and private ,

ecr - to publish the images ,

eks- cluster and nodes where everything will be deployed.

iam-roles  - are created but not used in the project as for eks we have used the modules in which the iam roles are already given .

providers - this file gives info. about the service we are going to use.

sg - security groups helps us  limit access and add  regulations.
    port no. to access kubernetes cluster is 443 - 80 for http, 3500 for our backend .

Internet
                    |
                Internet Gateway
                    |
           -------------------------
           |                       |
      Public Subnet           Public Subnet
           |                       |
         ALB                   NAT Gateway
                                   |
                              ---------------
                              |             |
                       Private Subnet   Private Subnet
                              |             |
                          EKS Nodes     EKS Nodes
                              |
                             Pods



  