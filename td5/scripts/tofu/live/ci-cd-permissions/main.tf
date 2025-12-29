provider "aws" {
  region = "us-east-2"
}

module "oidc_provider" {
  source = "../../modules/github-aws-oidc"
  provider_url = "https://token.actions.githubusercontent.com"
}

module "iam_roles" {
  source = "../../modules/gh-actions-iam-roles"
  name = "lambda-sample"
  oidc_provider_arn = module.oidc_provider.oidc_provider_arn
  enable_iam_role_for_testing = true
  enable_iam_role_for_plan = true
  enable_iam_role_for_apply = true
  github_repo = "TomWmbk/Devops_Lab"
  lambda_base_name = "lambda-sample"
  tofu_state_bucket = "tom-tf-state-2025"
  tofu_state_dynamodb_table = "tom-tf-locks"
}
