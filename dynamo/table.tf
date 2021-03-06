
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  backend "s3" {
    region         = "us-east-1"
    bucket         = "downloadpdf-390613502029"
    key            = "infrastucture/dynamo/terraform.tfstate"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }

  required_version = ">= 0.14.9"
}

data "aws_caller_identity" "current" {}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_dynamodb_table_item" "downloadpdf" {
  for_each = var.host_mapping
  table_name =  aws_dynamodb_table.downloadpdf.name
  hash_key   = aws_dynamodb_table.downloadpdf.hash_key

  item = <<ITEM
{
  "${var.hash_key}": {"S": "${each.key}"},
  "Source": {"S": "${each.value}"}
}
ITEM
}

resource "aws_dynamodb_table" "downloadpdf" {
  name           = var.name
  read_capacity  = 5
  write_capacity = 5
  hash_key       = var.hash_key

  attribute {
    name = var.hash_key
    type = "S"
  }

}