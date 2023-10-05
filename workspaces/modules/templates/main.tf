data "tfe_organization" "summercloud" {
  name = "summer-cloud-2023"
}

resource "tfe_workspace" "test" {
    name = "infra-fred"
    organization = data.tfe_organization.summercloud.name
    execution_mode = "local"
}