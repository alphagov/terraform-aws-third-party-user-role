data "aws_iam_policy_document" "policy_doc" {
  statement {
    sid     = "1"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [var.remote_user_arn]
    }

    condition {
      test     = var.mfa_required ? "Bool" : "StringLike"
      variable = var.mfa_required ? "aws:MultiFactorAuthPresent" : "aws:PrincipalArn"
      values   = var.mfa_required ? ["true"] : ["*"]
    }

    condition {
      test     = var.restrict_to_source_ips ? "IpAddress" : "StringLike"
      variable = var.restrict_to_source_ips ? "aws:SourceIp" : "aws:PrincipalArn"
      values   = var.restrict_to_source_ips ? var.source_ips : ["*"]
    }

    condition {
      test     = var.restrict_to_dates ? "DateGreaterThan" : "StringLike"
      variable = var.restrict_to_dates ? "aws:CurrentTime" : "aws:PrincipalArn"
      values   = var.restrict_to_dates ? [var.date_greater_than] : ["*"]
    }

    condition {
      test     = var.restrict_to_dates ? "DateLessThan" : "StringLike"
      variable = var.restrict_to_dates ? "aws:CurrentTime" : "aws:PrincipalArn"
      values   = var.restrict_to_dates ? [var.date_less_than] : ["*"]
    }
  }
}

data "external" "throw_error_restrict_to_dates_1" {
    # test whether restrict_to_dates is false but a date is set
    count = !var.restrict_to_dates && (var.date_greater_than != "*" || var.date_less_than != "*") ? 1 : 0
    program = ["/na/error - Invalid date configuration: restrict_to_dates is false but one or more date is set", "throw 'An error has ocurred.'"]
}
data "external" "throw_error_restrict_to_dates_2" {
    # test whether restrict_to_dates is true but a date is not set
    count = var.restrict_to_dates && (var.date_greater_than == "*" || var.date_less_than == "*") ? 1 : 0
    program = ["/na/error - Invalid date configuration: restrict_to_dates is true but one or more date is not set", "throw 'An error has ocurred.'"]
}
data "external" "throw_error_restrict_to_source_ips_1" {
    # test whether restrict_to_source_ips is true but no source IPs are set
    count = var.restrict_to_source_ips && length(var.source_ips) == 0 ? 1 : 0
    program = ["/na/error - Invalid source IPs configuration: restrict_to_source_ips is true but no source IP(s) are set", "throw 'An error has ocurred.'"]
}
data "external" "throw_error_restrict_to_source_ips_2" {
    # test whether restrict_to_source_ips is false but source IPs are set
    count = !var.restrict_to_source_ips && length(var.source_ips) != 0 ? 1 : 0
    program = ["/na/error - Invalid source IPs configuration: restrict_to_source_ips is false but source IP(s) are set", "throw 'An error has ocurred.'"]
}

resource "aws_iam_role" "third_party_user_role" {
  name = var.role_name
  assume_role_policy = data.aws_iam_policy_document.policy_doc.json
}

resource "aws_iam_role_policy_attachment" "third_party_user_role_policy_att" {
  count      = length(var.iam_policy_arns)
  role       = aws_iam_role.third_party_user_role.name
  policy_arn = element(var.iam_policy_arns, count.index)
}
