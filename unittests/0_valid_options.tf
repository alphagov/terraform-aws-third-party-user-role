module "valid_all_options" {
  role_name              = "test_role"
  remote_user_arn        = "arn:aws:iam::ACCOUNT-ID:user/USER"
  iam_policy_arns        = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  mfa_required           = true
  restrict_to_dates      = true
  date_greater_than      = "2020-12-01T00:00:00Z"
  date_less_than         = "2021-01-01T00:00:00Z"
  restrict_to_source_ips = true
  source_ips             = ["192.168.2.0/24","192.168.5.0/24",]
  source                 = "../../terraform-aws-third-party-user-role"
}
# expect:module.valid_all_options=N/A

module "valid_no_options" {
  role_name              = "test_role"
  remote_user_arn        = "arn:aws:iam::ACCOUNT-ID:user/USER"
  iam_policy_arns        = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  source                 = "../../terraform-aws-third-party-user-role"
}
# expect:module.valid_no_options=N/A
