terraform {
  cloud {
    organization = "summer-cloud-2023"

    workspaces {
      name = "infra-vpc"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}


