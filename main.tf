provider "aws" {
  # profile = "default"
  region = var.region
}

locals {
  bucket_name = "${var.name}-s3-bucket-${random_pet.this.id}"
}

resource "random_pet" "this" {
  length = 2
}


resource "aws_iam_role" "this" {
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

  managed_policy_arns = [aws_iam_policy.policy_one.arn, aws_iam_policy.policy_two.arn]
}

resource "aws_iam_policy" "policy_one" {
  #   name = "policy-618033"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["ec2:*"]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_policy" "policy_two" {
  #   name = "policy-381966"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:*"]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.this.arn]
    }

    actions = [
      "s3:*",
    ]

    resources = [
      "arn:aws:s3:::${local.bucket_name}",
      "arn:aws:s3:::${local.bucket_name}/*",
    ]
  }
}

# General Bucket #
module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket        = local.bucket_name
  acl           = "private"
  force_destroy = true

  attach_policy = true
  policy        = data.aws_iam_policy_document.bucket_policy.json

  versioning = {
    enabled = false
  }

#   website = {
#     index_document = "index.html"
#     error_document = "error.html"
#     routing_rules = jsonencode([{
#       Condition : {
#         KeyPrefixEquals : "docs/"
#       },
#       Redirect : {
#         ReplaceKeyPrefixWith : "documents/"
#       }
#     }])
#   }

#   logging = {
#     target_bucket = module.log_bucket.this_s3_bucket_id
#     target_prefix = "log/"
#   }



  # S3 bucket-level Public Access Block configuration
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  tags = var.tags

}


# Log Bucket #
module "log_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  lifecycle_rule = [
    {
      id      = "log"
      enabled = true
      prefix  = "log/"

      tags = {
        rule      = "log"
        autoclean = "true"
      }

      transition = [
        {
          days          = 30
          storage_class = "ONEZONE_IA"
          }, {
          days          = 60
          storage_class = "GLACIER"
        }
      ]

      expiration = {
        days = 90
      }

      noncurrent_version_expiration = {
        days = 30
      }
    },
    {
      id                                     = "log1"
      enabled                                = true
      prefix                                 = "log1/"
      abort_incomplete_multipart_upload_days = 7

      noncurrent_version_transition = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 60
          storage_class = "ONEZONE_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        },
      ]

      noncurrent_version_expiration = {
        days = 300
      }
    },
  ]

  bucket                         = "${var.name}-logs-${random_pet.this.id}"
  acl                            = "log-delivery-write"
  force_destroy                  = true
  attach_elb_log_delivery_policy = true
}


# CloudFront Bucket #
data "aws_canonical_user_id" "current" {}

module "cloudfront_log_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "${var.name}-cloudfront-logs-${random_pet.this.id}"
  acl    = null # conflicts with default of `acl = "private"` so set to null to use grants
  grant = [
    {
      type        = "CanonicalUser"
      permissions = ["FULL_CONTROL"]
      id          = data.aws_canonical_user_id.current.id
    },
    # {
    # type        = "CanonicalUser"
    # permissions = ["FULL_CONTROL"]
    # id          = "c4c1ede66af53448b93c283ce9448c4ba468c9432aa01d700d3878632f77d2d0"
    # # Ref. https://github.com/terraform-providers/terraform-provider-aws/issues/12512
    # # Ref. https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html
    # }
  ]
  force_destroy = true
}
