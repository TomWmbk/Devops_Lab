variable "name" {}
variable "oidc_provider_arn" {}
variable "github_repo" {}

# Variables optionnelles
variable "lambda_base_name" { default = "" }
variable "tofu_state_bucket" { default = "" }
variable "tofu_state_dynamodb_table" { default = "" }
variable "enable_iam_role_for_testing" { default = true }
variable "enable_iam_role_for_plan" { default = true }
variable "enable_iam_role_for_apply" { default = true }

# Politique de confiance
data "aws_iam_policy_document" "github_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repo}:*"]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

# Rôle de Test
resource "aws_iam_role" "test" {
  name               = "${var.name}-tests"
  assume_role_policy = data.aws_iam_policy_document.github_trust.json
}
resource "aws_iam_role_policy_attachment" "test_admin" {
  role       = aws_iam_role.test.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Rôle de Plan
resource "aws_iam_role" "plan" {
  name               = "${var.name}-plan"
  assume_role_policy = data.aws_iam_policy_document.github_trust.json
}
resource "aws_iam_role_policy_attachment" "plan_admin" {
  role       = aws_iam_role.plan.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Rôle d'Apply
resource "aws_iam_role" "apply" {
  name               = "${var.name}-apply"
  assume_role_policy = data.aws_iam_policy_document.github_trust.json
}
resource "aws_iam_role_policy_attachment" "apply_admin" {
  role       = aws_iam_role.apply.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Outputs
output "lambda_test_role_arn" { value = aws_iam_role.test.arn }
output "lambda_deploy_plan_role_arn" { value = aws_iam_role.plan.arn }
output "lambda_deploy_apply_role_arn" { value = aws_iam_role.apply.arn }
