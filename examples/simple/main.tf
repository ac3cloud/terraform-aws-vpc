provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  name   = "victor-test-vpc"
  region = "ap-southeast-2"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 2)

  tags = {
    Example    = local.name
  }
}

################################################################################
# VPC Module
################################################################################

module "vpc" {
  source = "../../"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 2, k)]

  tags = local.tags
}
