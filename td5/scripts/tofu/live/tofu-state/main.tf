provider "aws" { region = "us-east-2" }
module "state" {
  source = "../../modules/state-bucket"
  name = "tom-tf-state-2025"
}
