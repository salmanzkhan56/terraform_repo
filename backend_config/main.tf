provider "aws" {
  region = var.region
}

###--1  Creating S3 bucket.
resource "aws_s3_bucket" "terraform_state" {
bucket = "terraform-state-12202023"
# Prevent accidental deletion of this S3 bucket

#lifecycle {
#prevent_destroy = true
#}
}
###--2  Enabling versioning
resource "aws_s3_bucket_versioning" "enabled" {
bucket = aws_s3_bucket.terraform_state.id
versioning_configuration {
status = "Enabled"
}
}
###--3  Blocking public access.
resource "aws_s3_bucket_public_access_block" "public_access" {
bucket = aws_s3_bucket.terraform_state.id
block_public_acls = true
block_public_policy = true
ignore_public_acls = true
restrict_public_buckets = true
}

###--4  Creating dynamodb table to log locking.
resource "aws_dynamodb_table" "terraform_locks" {
name = "terraform-up-and-running-locks-12202023"
billing_mode = "PAY_PER_REQUEST"
hash_key = "LockID"
attribute {
name = "LockID"
type = "S"
}
}

###--5  Storing State remotely on AWS-S3

terraform {
backend "s3" {
#Replace this with your bucket name!
bucket = "terraform-state-12202023"
key = "global/s3/terraform.tfstate"
region = "eu-central-1"	#Variable isn't acceptable in Terraform block
#Replace this with your DynamoDB table name!
dynamodb_table = "terraform-up-and-running-locks-12202023"
encrypt = true
}
}
output "s3_bucket_arn" {
value = aws_s3_bucket.terraform_state.arn
description = "The ARN of the S3 bucket"
}
output "dynamodb_table_name" {
value = aws_dynamodb_table.terraform_locks.name
description = "The name of the DynamoDB table"
}
