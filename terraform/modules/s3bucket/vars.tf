variable "aws_bucket_name" {
    description = "The name of the bucket. If omitted, Terraform will assign a random, unique name."
}
variable "bucket_acl" {
    description = "The canned ACL to apply. Defaults to private"
}

variable "versioning" {
    description = "A state of versioning"
}

variable "aws_region" {
    description = "If specified, the AWS region this bucket should reside in"
}

variable "aws_environment" {}
