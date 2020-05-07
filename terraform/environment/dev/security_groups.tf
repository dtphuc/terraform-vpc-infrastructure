resource "aws_security_group" "this" {
  name        = "${var.aws_environment}-sgr"

  # Allow all inbound
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [module.alb.alb_security_group_rules]
    description = "Allow All from ALB"
  }

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id   = "${data.terraform_remote_state.dev_vpc.outputs.vpc_id}"
  tags = {
    Environment = var.aws_environment
  }
}
