terraform {
    backend "s3" {
        bucket = "paytrack-cloud-tf-state-bucket"
        key    = "environments/dev/terraform.tfstate"
        region = "eu-west-1"
        dynamodb_table = "paytrack-cloud-tf-state-bucket-lock"
        use_lockfile = true
        encrypt = true
    }
}