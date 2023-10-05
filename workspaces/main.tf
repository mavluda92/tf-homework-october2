terraform {
  cloud {
    organization = "summer-cloud-2023"

    workspaces {
      name = "infra-workspaces"
    }
  }

  required_providers {
    tfe = {
      version = "~> 0.49.0"
    }
  }
}

provider "tfe" {
  version = "~> 0.49.0"
}

data "tfe_organization" "summercloud" {
  name = "summer-cloud-2023"
}

locals {
  infra-components = [
    "vpc",
    "subnet",
    "ec2"
  ]
  exec_type = "local"
}

resource "tfe_workspace" "test" {
  #for_each = [ for w in local.local.infra-components : w ]
  for_each       = toset(local.infra-components)
  name           = "infra-${each.key}"
  organization   = data.tfe_organization.summercloud.name
  execution_mode = local.exec_type
}