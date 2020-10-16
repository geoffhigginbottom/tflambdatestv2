### AWS Auth Configuration ###
provider "aws" {
  profile    = var.profile
  region     = lookup(var.aws_region, var.region)
}

module "iam" {
  source = "./modules/iam"
}

### Modules ###

module "one" {
  source = "./modules/functions/one"
  lambda_initiate_lambda_role_arn = module.iam.lambda_initiate_lambda_role_arn
  lambda_function_two_arn = module.two.lambda_function_two_arn
  function_one_name = var.function_one_name
  function_one_url = var.function_one_url

  region = var.region
  region_wrapper = var.region_wrapper
  access_token = var.access_token
  realm = var.realm
  metrics_url = var.metrics_url
  metrics_tracing = var.metrics_tracing
  apm_environment = var.apm_environment
}

module "two" {
  source = "./modules/functions/two"
  lambda_initiate_lambda_role_arn = module.iam.lambda_initiate_lambda_role_arn
  function_two_name = var.function_two_name
  function_two_url = var.function_two_url

  region = var.region
  region_wrapper = var.region_wrapper
  access_token = var.access_token
  realm = var.realm
  metrics_url = var.metrics_url
  metrics_tracing = var.metrics_tracing
  apm_environment = var.apm_environment
}

module "three" {
  source = "./modules/functions/three"
  lambda_initiate_lambda_role_arn = module.iam.lambda_initiate_lambda_role_arn
  function_three_name = var.function_three_name
  function_three_url = var.function_three_url

  region = var.region
  region_wrapper = var.region_wrapper
  access_token = var.access_token
  realm = var.realm
  metrics_url = var.metrics_url
  metrics_tracing = var.metrics_tracing
  apm_environment = var.apm_environment
}

module "four" {
  source = "./modules/functions/four"
  lambda_initiate_lambda_role_arn = module.iam.lambda_initiate_lambda_role_arn
  function_four_name = var.function_four_name
  function_four_url = var.function_four_url

  region = var.region
  region_wrapper = var.region_wrapper
  access_token = var.access_token
  realm = var.realm
  metrics_url = var.metrics_url
  metrics_tracing = var.metrics_tracing
  apm_environment = var.apm_environment
}

# module "xxx" {
#   source = "./modules/functions/xxx"
#   lambda_initiate_lambda_role_arn = module.iam.lambda_initiate_lambda_role_arn
#   function_xxx_name = var.function_xxx_name
#   function_xxx_url = var.function_xxx_url

#   region = var.region
#   region_wrapper = var.region_wrapper
#   access_token = var.access_token
#   realm = var.realm
#   metrics_url = var.metrics_url
#   metrics_tracing = var.metrics_tracing
#   apm_environment = var.apm_environment
# }
