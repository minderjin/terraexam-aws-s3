###############################################################################################################################################################################
# Terraform loads variables in the following order, with later sources taking precedence over earlier ones:
# 
# Environment variables
# The terraform.tfvars file, if present.
# The terraform.tfvars.json file, if present.
# Any *.auto.tfvars or *.auto.tfvars.json files, processed in lexical order of their filenames.
# Any -var and -var-file options on the command line, in the order they are provided. (This includes variables set by a Terraform Cloud workspace.)
###############################################################################################################################################################################
#
# terraform cloud 와 별도로 동작
# terraform cloud 의 variables 와 동등 레벨
#
# Usage :
#
#   terraform apply -var-file=terraform.tfvars
#
#
# [Terraform Cloud] Environment Variables
#
#     AWS_ACCESS_KEY_ID
#     AWS_SECRET_ACCESS_KEY
#

name   = "example"
region = "us-west-2"

tags = {
  Terraform   = "true"
  Environment = "dev"
}

bucket_name   = "example-test-bucket-name"
acl           = "private"
force_destroy = true
attach_policy = true
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
