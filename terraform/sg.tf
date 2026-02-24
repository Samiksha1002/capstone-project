#ALB Security Group (Public Facing)

resource "aws_security_group" "alb_sg" {
  name   = "capstone-alb-sg"
  vpc_id = aws_vpc.project_vpc.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "alb-sg"
  }
}

#EKS Node Security Group (Private)
resource "aws_security_group" "eks_nodes_sg" {
  name   = "capstone-eks-nodes-sg"
  vpc_id = aws_vpc.project_vpc.id

  # SSH (restrict to your IP)
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Change this to your IP for better security
  }
  # Allow frontend from ALB
  ingress {
    description     = "Frontend 3000 from ALB"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  
  # Backend port from ALB only
  ingress {
    description     = "Backend 3500 from ALB"
    from_port       = 3500
    to_port         = 3500
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Allow node outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "eks-nodes-sg"
  }
}