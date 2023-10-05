terraform {
  cloud {
    organization = "summer-cloud-2023"

    workspaces {
      name = "infra-ec2"
    }
  }
}