terraform {}

provider "template" {
  version = "~> 2.1"
}

provider "aws" {
  version = "~> 2.28"
  region = local.aws_region
}

provider "external" {
  version = "~> 1.2.0"
}

module "vpc" {
  source = "./modules/vpc"
  vpc_name = local.vpc_name
}
