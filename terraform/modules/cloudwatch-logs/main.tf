resource "aws_cloudwatch_log_group" "this" {
    name              = "${var.aws_cloudwatch_log_name}"
    retention_in_days = "${var.retention_in_days}"
    tags = {
        Name        = "${var.aws_cloudwatch_log_name}"
        Environment = "${var.aws_environment}"
    }
}

resource "aws_cloudwatch_log_stream" "this" {
  name           = "${var.aws_cloudwatch_logstream_name}"
  log_group_name = "${aws_cloudwatch_log_group.this.name}"
}