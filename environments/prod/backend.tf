terraform {
  backend "s3" {
    bucket         = "paytrack-state-121212"
    key            = "environments/prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "paytrack-tf-state-lock"

    endpoints = {
      s3       = "http://localhost:4566"
      dynamodb = "http://localhost:4566"
    }

    use_path_style              = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}