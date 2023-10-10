terraform {
  cloud {
    organization = "summer-cloud-2023"

    workspaces {
      name = "infra-billing"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

module "billing_alert" {
  source = "binbashar/cost-billing-alarm/aws"

  aws_env = "mali"
  monthly_billing_threshold = 30
  currency = "USD"
  create_sns_topic = true
}

resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = module.billing_alert.sns_topic_arns[0]
  protocol  = "email"
  endpoint  = "mavluda.kambarova@gmail.com"
}

