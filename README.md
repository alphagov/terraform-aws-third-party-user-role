# terraform-aws-third-party-user-role
Terraform module for an AWS third party user role - includes optional conditions such as MFA, source IPs and between dates

``` hcl
module "valid_all_options" {
  # arbitrary role name
  role_name              = "firstname.lastname_ReadOnlyAccess"

  # ARN of a user account that can assume this role
  remote_user_arn        = "arn:aws:iam::ACCOUNT-ID:user/firstname.lastname"

  # local policy ARN(s) to apply to this role
  iam_policy_arns        = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]

  # if the MFA is required to assume this role
  mfa_required           = true

  # whether this role can only be assumed between certain dates
  restrict_to_dates      = true
  date_greater_than      = "2020-12-01T00:00:00Z"
  date_less_than         = "2021-01-01T00:00:00Z"

  # whether this role can only be assumed from certain IP ranges
  restrict_to_source_ips = true
  source_ips             = ["192.168.2.0/24","192.168.5.0/24",]

  source                 = "github.com/alphagov/terraform-aws-third-party-user-role"
}
```
