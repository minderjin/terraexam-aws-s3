variable "name" {}
variable "region" {}
variable "tags" {}

variable "bucket_name" {}
variable "acl" {}
variable "force_destroy" {}
variable "attach_policy" {}
variable "versioning" {}

# S3 bucket-level Public Access Block configuration
variable "block_public_acls" {}
variable "block_public_policy" {}
variable "ignore_public_acls" {}
variable "restrict_public_buckets" {}
