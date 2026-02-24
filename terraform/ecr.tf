# This file defines the AWS ECR repositories for the frontend and backend images.
resource "aws_ecr_repository" "frontend-img" {
  name                 = "frontend-img"
  image_tag_mutability = "IMMUTABLE_WITH_EXCLUSION"


  image_tag_mutability_exclusion_filter {
    filter      = "latest*"
    filter_type = "WILDCARD"
  }

  image_scanning_configuration {
    scan_on_push = true
  }
  tags ={
    Name = "frontend-img"
  }
}


resource "aws_ecr_repository" "backend-img" {
  name                 = "backend-img"
  image_tag_mutability = "IMMUTABLE_WITH_EXCLUSION"


  image_tag_mutability_exclusion_filter {
    filter      = "latest*"
    filter_type = "WILDCARD"
  }

  image_scanning_configuration {
    scan_on_push = true
  }
  tags ={
    Name = "backend-img"
  }
}