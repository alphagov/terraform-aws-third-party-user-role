module "dates_should_not_be_set" {
  role_name              = "test_role"
  remote_user_arn        = "arn:aws:iam::ACCOUNT-ID:user/USER"
  iam_policy_arns        = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  restrict_to_dates      = false
  date_greater_than      = "2020-12-01T00:00:00Z"
  date_less_than         = "2021-01-01T00:00:00Z"
  source                 = "../../terraform-aws-third-party-user-role"
}
# expect:module.dates_should_not_be_set=Invalid date configuration: restrict_to_dates is false but one or more date is set

module "dates_should_be_set" {
  role_name              = "test_role"
  remote_user_arn        = "arn:aws:iam::ACCOUNT-ID:user/USER"
  iam_policy_arns        = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  restrict_to_dates      = true
  source                 = "../../terraform-aws-third-party-user-role"
}
# expect:module.dates_should_be_set=Invalid date configuration: restrict_to_dates is true but one or more date is not set
