terraform {
    backend "s3" {
        bucket = "alanlviana-terraform-backend"
        key = "terraform-aws-study-app/dev.tfstate"
        region = "sa-east-1"
        dynamodb_table = "terraform-aws-study-app-dev"
        encrypt = true
    }
}