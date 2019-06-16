resource "aws_s3_bucket" "this" {
    bucket  = "${var.aws_bucket_name}"
    acl     = "${var.bucket_acl}"
    region  = "${var.aws_region}"
    versioning {
        enabled = "${var.versioning}"
    }
    tags = {
        Name        = "${var.aws_bucket_name}"
        Environment = "${var.aws_environment}"
    }
}