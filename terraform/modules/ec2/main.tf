/*
# Create a on-demand EC2 instance in VPC public subnet
*/
resource "aws_instance" "this" {
  count                       = var.aws_instance_count
  ami                         = var.ami_id
  instance_type               = var.aws_instance_type
  user_data                   = var.user_data
  subnet_id                   = sort(var.subnet_id)[count.index]
  key_name                    = var.aws_key_name
  vpc_security_group_ids      = var.vpc_security_group_ids
  iam_instance_profile        = var.iam_instance_profile
  associate_public_ip_address = var.associate_public_ip_address
  disable_api_termination     = var.disable_api_termination

  root_block_device {
      volume_size = var.root_volume_size
      volume_type = var.root_volume_type
      encrypted   = var.encrypted
  }
  tags = {
    Name        = element(var.instance_name, count.index)
    Class       = element(var.instance_class, count.index)
    Environment = var.aws_environment
    Comment     = var.aws_description
    Description = var.aws_description
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [key_name]
  }
}

