provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Name = "tf-sagemaker-sandbox"
    }
  }
}

data "aws_availability_zones" "default" {}

resource "aws_sagemaker_domain" "default" {
  domain_name = "tf-sagemaker-sandbox"
  auth_mode   = "IAM"

  subnet_ids  =  [for s in aws_subnet.private : s.id]

  vpc_id      = aws_vpc.client.id

  app_network_access_type = "VpcOnly"

  default_user_settings {
    execution_role = aws_iam_role.sagemaker.arn
    security_groups = [aws_security_group.sagemaker_domain.id]
  }
}
#
#resource "aws_sagemaker_app" "jupyter_server" {
#  app_name          = "default"
#  app_type          = "JupyterServer"
#  domain_id         = aws_sagemaker_domain
#  user_profile_name = aws_sagemaker_user_profile.default.user_profile_name
#}

resource "aws_security_group" "sagemaker_domain" {
  vpc_id = aws_vpc.client.id
  name = "tf-sagemaker-sandbox"
}

resource "aws_security_group_rule" "sagemaker_domain_egress_all" {
  security_group_id = aws_security_group.sagemaker_domain.id

  type        = "egress"
  protocol    = "-1"
  from_port   = 0
  to_port     = 0
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_sagemaker_user_profile" "default" {
  domain_id         = aws_sagemaker_domain.default.id
  user_profile_name = "tf-sagemaker-sandbox-user"
}

resource "aws_iam_role" "sagemaker" {
  name               = "tf-sagemaker-sandbox"
  assume_role_policy = data.aws_iam_policy_document.sagemaker_assume.json
}

data "aws_iam_policy_document" "sagemaker_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["sagemaker.amazonaws.com"]
    }
  }
}

#resource "aws_iam_policy" "sagemaker_execution_role" {
#  name = "tf-sagemaker-sandbox-execution"
#  policy = file("templates/iam/policy/sagemaker-execution.json")
#}

resource "aws_iam_role_policy_attachment" "sagemaker_execution_role" {
  role       = aws_iam_role.sagemaker.id
#  policy_arn = aws_iam_policy.sagemaker_execution_role.arn
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}