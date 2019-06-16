
resource "aws_iam_group" "this" {
    name = "${var.group_name}"
    path = "${var.group_path}"
}

resource "aws_iam_group_policy" "group_policy" {
    group = "${aws_iam_group.this.id}"
    name  = "${var.group_policy_name}"
    policy = "${var.group_policy}"
}

resource "aws_iam_user" "this" {
  name = "${var.iam_username}"
  path = "${var.iam_user_path}"
}

resource "aws_iam_user_group_membership" "this" {
  user = "${aws_iam_user.this.name}"

  groups = [
    "${aws_iam_group.this.name}",
  ]
}