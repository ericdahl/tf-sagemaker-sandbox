provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Name = "private-link-cross-region"
    }
  }
}

data "aws_availability_zones" "default" {}

resource "aws_sagemaker_domain" "default" {
  domain_name = "tf-sagemaker-sandbox"
  auth_mode   = "IAM"

  subnet_ids  =  [for s in aws_subnet.private : s.id]

  vpc_id      = aws_vpc.client.id

  app_network_access_type = "PublicInternetOnly"

  default_user_settings {
    execution_role = aws_iam_role.sagemaker.arn
  }
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