terraform {
  cloud {
    organization = "summer-cloud-2023"

    workspaces {
      name = "infra-subnet"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "vpc_id" {
 default = "vpc-0aa883d9f3240128a"
}

data "aws_vpc" "main" {
  id = var.vpc_id
}

resource "aws_subnet" "main" {
  vpc_id     = data.aws_vpc.main.id
  cidr_block = cidrsubnet(data.aws_vpc.main.cidr_block, 4, 1)

  tags = {
    Name = "Main"
  }
}