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
    key            = "infrastucture/hostname/terraform.tfstate"
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

data "aws_route53_zone" "lookup" {
  name = "${var.dns_domain}"
}

resource "aws_route53_record" "hostname" {
  for_each = var.host_mapping
  name = "${each.key}"
  zone_id = data.aws_route53_zone.lookup.id
  type    = "CNAME"
  ttl     = "1"
  records = ["stashedup.github.io"]
}
