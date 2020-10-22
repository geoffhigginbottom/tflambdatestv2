### AWS Variables ###
variable "region" {}
variable "region_wrapper" {}

### Terraform Variables ###
variable "lambda_initiate_lambda_role_arn" {}
variable "lambda_function_retailorderline_arn" {}
variable "retailorderprice_base_url" {}

### SFx Variables ###
variable "access_token" {}
variable "realm" {}
variable "metrics_url" {}
variable "metrics_tracing" {}
variable "apm_environment" {}

### Function Names ###
variable "function_retailorder_name" {}

### Function URLs ###
variable "function_retailorder_url" {}
