terraform {
  cloud {
    organization = "summer-cloud-2023"

    workspaces {
      name = "infra-billing-v2"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
locals {

  alarm = {
    name                = "account-billing-alarm-${lower(var.currency)}-${var.aws_env}"
    description         = var.aws_account_id == null ? "Billing consolidated alarm >= ${var.currency} ${var.monthly_billing_threshold}" : "Billing alarm account ${var.aws_account_id} >= ${var.currency} ${var.monthly_billing_threshold}"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods  = "1"
    metric_name         = "EstimatedCharges"
    namespace           = "AWS/Billing"
    period              = "28800"
    statistic           = "Maximum"
    threshold           = var.monthly_billing_threshold
    alarm_actions       = var.create_sns_topic ? concat([aws_sns_topic.sns_alert_topic.arn], var.sns_topic_arns) : var.sns_topic_arns

    dimensions = {
      currency       = var.currency
      linked_account = var.aws_account_id
    }
  }

}

#=============================#
# Cloudwatch Billing alert    #
#=============================#
variable "aws_env" {
  description = "AWS environment you are deploying to. Will be appended to SNS topic and alarm name. (e.g. dev, stage, prod)"
  type        = string
  default = "ziyotek_v2"
}

variable "monthly_billing_threshold" {
  description = "The threshold for which estimated monthly charges will trigger the metric alarm."
  type        = string
  default = "30"
}

variable "currency" {
  description = "Short notation for currency type (e.g. USD, CAD, EUR)"
  type        = string
  default     = "USD"
}

variable "aws_account_id" {
  description = "AWS account id"
  type        = string
  default     = null
}

variable "datapoints_to_alarm" {
  description = "The number of datapoints that must be breaching to trigger the alarm."
  type        = number
  default     = null
}

#=============================#
# SNS                         #
#=============================#
variable "create_sns_topic" {
  description = "Creates a SNS Topic if `true`."
  type        = bool
  default     = true
}


variable "sns_topic_arns" {
  description = "List of SNS topic ARNs to be used. If `create_sns_topic` is `true`, it merges the created SNS Topic by this module with this list of ARNs"
  type        = list(string)
  default     = []
}

resource "aws_cloudwatch_metric_alarm" "account_billing_alarm" {
  alarm_name          = lookup(local.alarm, "name")
  alarm_description   = lookup(local.alarm, "description")
  comparison_operator = lookup(local.alarm, "comparison_operator")
  evaluation_periods  = lookup(local.alarm, "evaluation_periods", "1")
  metric_name         = lookup(local.alarm, "metric_name")
  namespace           = lookup(local.alarm, "namespace", "AWS/Billing")
  period              = lookup(local.alarm, "period", "28800")
  statistic           = lookup(local.alarm, "statistic", "Maximum")
  threshold           = lookup(local.alarm, "threshold")
  alarm_actions       = lookup(local.alarm, "alarm_actions")
  datapoints_to_alarm = var.datapoints_to_alarm

  dimensions = {
    Currency      = lookup(lookup(local.alarm, "dimensions"), "currency")
    LinkedAccount = lookup(lookup(local.alarm, "dimensions"), "linked_account", null)
  }

}

# SNS Topic
resource "aws_sns_topic" "sns_alert_topic" {
  name  = "billing-alarm-notification-${lower(var.currency)}-${var.aws_env}"
}

resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = aws_sns_topic.sns_alert_topic.arn
  protocol  = "email"
  endpoint  = "mavluda.kambarova@gmail.com"
}
