#main vpc
resource "aws_vpc" "project_vpc" {
  cidr_block           = var.my_vpc_main_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "proj_vpc"
  }
}

#---------------------------------------------------------------------------------------------------------------
#create 4 subnets , 2 public and 2 private

#SUBNET-01 -PUBLIC
resource "aws_subnet" "public_subnet_01" {
  vpc_id            = aws_vpc.project_vpc.id
  cidr_block        = var.public_subnet_cidr[0]
  availability_zone = var.aws_availability_zone[0]
  tags = {
    Name                             = "pub_subnet_1"
    "kubernetes.io/role/elb"         = "1"      # This tag is used to identify subnets that are suitable for load balancers in Kubernetes.
    "kubernetes.io/cluster/capstone" = "shared" # Marks this subnet as shared with the "capstone" EKS cluster,
    # allowing EKS to automatically use it for nodes and load balancers.

  
  }
}
#SUBNET--02 -PUBLIC
resource "aws_subnet" "public_subnet_02" {
  vpc_id            = aws_vpc.project_vpc.id
  cidr_block        = var.public_subnet_cidr[1]
  availability_zone = var.aws_availability_zone[1]
  tags = {
    Name                             = "pub_subnet_2"
    "kubernetes.io/role/elb"         = "1" # By tagging the subnet with "kubernetes.io/role/elb" = "1", we indicate that this subnet can be used for provisioning Elastic Load Balancers (ELBs) in the EKS cluster. This allows Kubernetes to automatically select this subnet when creating ELBs for services of type LoadBalancer, ensuring that the load balancers are placed in the appropriate subnets for optimal performance and availability.
    "kubernetes.io/cluster/capstone" = "shared"
  }
}

#SUBNET-03 - PRIVATE 
resource "aws_subnet" "private_subnet_01" {
  vpc_id            = aws_vpc.project_vpc.id
  cidr_block        = var.private_subnet_cidr[0]
  availability_zone = var.aws_availability_zone[0]
  tags = {
    Name                              = "priv_subnet_1"
    "kubernetes.io/role/internal-elb" = "1" # This tag is used to identify subnets that are suitable for internal load balancers in Kubernetes. By tagging the subnet with "kubernetes.io/role/internal-elb" = "1", we indicate that this subnet can be used for provisioning internal Elastic Load Balancers (ELBs) in the EKS cluster. This allows Kubernetes to automatically select this subnet when creating ELBs for services of type LoadBalancer that are intended for internal use, ensuring that the load balancers are placed in the appropriate subnets for optimal performance and security.
    "kubernetes.io/cluster/capstone"  = "shared"
  }

}

#SUBNET-04 - PRIVATE 
resource "aws_subnet" "private_subnet_02" {
  vpc_id            = aws_vpc.project_vpc.id
  cidr_block        = var.private_subnet_cidr[1]
  availability_zone = var.aws_availability_zone[1]
  tags = {
    Name                              = "priv_subnet_2"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/capstone"  = "shared"
  }
}

#-------------------------------IGW-----------------------------------------------------
#INTERNET-GATEWAY
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.project_vpc.id

  tags = {
    Name = "igw"
  }

}

#NAT_GW
#Elastic- IP for NAT-GW-1
resource "aws_eip" "eip_1" {
  domain = "vpc"
  tags = {
    Name = "nat_gw_eip_1"
  }

}

#NAT-GW-1
resource "aws_nat_gateway" "nat_gw_1" {
  allocation_id = aws_eip.eip_1.id
  subnet_id     = aws_subnet.public_subnet_01.id
  tags = {
    Name = "nat_gw_1"
  }

}

#Elastic- IP for NAT-GW-2
resource "aws_eip" "eip_2" {
  domain = "vpc"
  tags = {
    Name = "nat_gw_eip_2"
  }

}

#NAT-GW-2
resource "aws_nat_gateway" "nat_gw_2" {
  allocation_id = aws_eip.eip_2.id
  subnet_id     = aws_subnet.public_subnet_02.id
  tags = {
    Name = "nat_gw_2"
  }

}

#routing_tables
#public route table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.project_vpc.id

  tags = {
    Name = "public_rt"
  }

}
#public_route_table
#route to internet via IGW	
resource "aws_route" "public_internet_access_1" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
 
}
#associate public subnets with public route table
resource "aws_route_table_association" "public_subnet_rt_association_01" {
  subnet_id      = aws_subnet.public_subnet_01.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_subnet_rt_association_02" {
  subnet_id      = aws_subnet.public_subnet_02.id
  route_table_id = aws_route_table.public_rt.id

}


#private_route_table-01 (az-1)
#route table for private subnets
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.project_vpc.id

  tags = {
    Name = "private_rt_01"
  }
}

#route to internet via NAT-GW
resource "aws_route" "private_1_nat" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw_1.id
}
#associate private subnets with private route tables
resource "aws_route_table_association" "private_subnet_rt_association_01" {
  subnet_id      = aws_subnet.private_subnet_01.id
  route_table_id = aws_route_table.private_rt.id
}

#private_route_table-02 (az-2)
#route table for private subnets

resource "aws_route_table" "private_rt_02" {
  vpc_id = aws_vpc.project_vpc.id

  tags = {
    Name = "private_rt_02"
  }
}

#route to internet via NAT-GW
resource "aws_route" "private_2_nat" {
  route_table_id         = aws_route_table.private_rt_02.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw_2.id
}
#associate private subnets with private route tables
resource "aws_route_table_association" "private_subnet_rt_association_02" {
  subnet_id      = aws_subnet.private_subnet_02.id
  route_table_id = aws_route_table.private_rt_02.id
}


