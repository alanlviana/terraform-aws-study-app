# Your bucket name, it must be unique in each environment
variable "spa_bucket_name" {
  description = "Bucket name, will keep static content for a SPA"
}

# Your lambda function name, it must be unique in each environment
variable "lambda_notification_name" {
  description = "Lambda notification name"
}


# Your execution role name, it must be unique in each environment
variable "lambda_notification_role_name" {
  description = "Lambda execution role name"
}

# Your policy name, it must be unique in each environment
variable "function_notification_policy" {
  description = "Lambda policy name"
}

