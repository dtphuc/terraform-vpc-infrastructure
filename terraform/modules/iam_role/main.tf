
resource "aws_iam_role" "this" {
    name = "${var.aws_role_name}"
    path = "/"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "this" {
    name   = "${var.aws_policy_name}"
    policy = "${var.aws_policy_rules}"
    role   = "${aws_iam_role.this.id}"
}

resource "aws_iam_instance_profile" "this" {
    name   = "${var.aws_profile_name}"
    path   = "/"
    role  = "${aws_iam_role.this.name}"
}