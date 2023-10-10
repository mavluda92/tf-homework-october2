terraform {
  cloud {
    organization = "summer-cloud-2023"

    workspaces {
      name = "infra-subnet"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
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

variable "subnets" {
  type = map(object({
    cidr_block = string
  }))
}

resource "aws_subnet" "main" {
  for_each   = var.subnets
  vpc_id     = data.aws_vpc.main.id
  cidr_block = each.value.cidr_block

  tags = {
    Name = each.key
  }
}