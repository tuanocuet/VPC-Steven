include {
  path = find_in_parent_folders()
}

dependency "elastic_ips" {
  config_path = "../elastic-ips"
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  account_id = local.account_vars.locals.account_id
  profile = local.account_vars.locals.profile
  environment = local.account_vars.locals.environment
  account_name = local.account_vars.locals.account_name
}

inputs = {
  name = "${local.environment}-vpc"
  cidr = "172.4.0.0/16"
  azs = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["172.4.1.0/24", "172.4.2.0/24", "172.4.3.0/24"]
  public_subnets = ["172.4.11.0/24", "172.4.12.0/24", "172.4.13.0/24"]
  database_subnets = ["172.4.111.0/24", "172.4.112.0/24", "172.4.113.0/24"]
  create_database_subnet_group = true
  enable_dns_support = true
  enable_dns_hostnames = true
  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false
  reuse_nat_ips = true
  external_nat_ip_ids = [dependency.elastic_ips.outputs.nat_gateway_eip_id]
  map_public_ip_on_launch = false
  tags = {
    "environment": "${local.environment}",
    "infrastructure-component": "vpc"
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/${local.environment}": "owned",
    "kubernetes.io/role/internal-elb": "1"
  }
  public_subnet_tags = {
    "kubernetes.io/cluster/${local.environment}": "shared",
    "kubernetes.io/role/elb": "1"
  }
  nat_gateway_tags = {
    "katalon:infrastructure-component": "nat-gateway"
  }
}

terraform {
    source = "${get_env("PWD")}/../cloudops-terraform-modules/aws//terraform-aws-vpc"
}

