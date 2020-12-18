variable "remote_user_arn" {}

variable "role_name" {}

variable "iam_policy_arns" {
  type = list
}

variable "mfa_required" {
  default = true
}

variable "restrict_to_source_ips" {
  default = false
}

variable "source_ips" {
  default = []
  type = list
}

variable "restrict_to_dates" {
  default = false
}

variable "date_greater_than" {
  default = "*"
}

variable "date_less_than" {
  default = "*"
}
