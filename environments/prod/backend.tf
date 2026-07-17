terraform{
    backend "s3" {
        bucket = "paytrack-state-121212"
        key    = "environments/prod/terraform.tfstate"
        region = "us-east-1"
        encrypt = true
        dynamodb_table = "paytrack-tf-state-lock"
    }
}