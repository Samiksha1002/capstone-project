
#vpc -------------variables-----------------
variable "my_vpc_main_cidr" {
  type        = string
  description = "The value is a CIDR Block assigned to main VPC"
  default     = "10.24.0.0/16"
}


#Subnet--------- varibales-------------------

variable "public_subnet_cidr" {
  type        = list(string)
  description = "Public Subnet CIDR values"
  default     = ["10.24.1.0/24", "10.24.50.0/24"]
}

variable "private_subnet_cidr" {
  type        = list(string)
  description = "Private Subnet CIDR values"
  default     = ["10.24.125.0/24", "10.24.144.0/24"]
}

variable "aws_availability_zone" {
  type        = list(string)
  description = "The value is availability zone from aws region"
  default     = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}




#EKS Cluster variables---------------------

variable "desired_capacity_on_demand" {
  description = "Desired number of on-demand worker nodes in the EKS cluster"
  type        = number
  default     = 2

}

variable "min_capacity_on_demand" {
  description = "Minimum number of on-demand worker nodes in the EKS cluster"
  type        = number
  default     = 2
}

variable "max_capacity_on_demand" {
  description = "Maximum number of on-demand worker nodes in the EKS cluster"
  type        = number
  default     = 4
}

#---------------------------------------------