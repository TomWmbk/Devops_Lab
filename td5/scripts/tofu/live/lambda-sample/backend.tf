terraform {
  backend "s3" {
    bucket = "tom-tf-state-2025"
    key    = "td5/lambda-sample"
    region = "us-east-2"
    encrypt = true
    dynamodb_table = "tom-tf-locks"
  }
}
