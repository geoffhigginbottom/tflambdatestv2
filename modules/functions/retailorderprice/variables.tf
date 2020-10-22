### AWS Variables ###
variable "region" {}
variable "region_wrapper" {}

### Terraform Variables ###
variable "lambda_initiate_lambda_role_arn" {}
variable "retaildiscount_invoke_url" {}
variable "retaildiscount_function_name" {}
variable "retaildiscount_stage_name" {}

### SFx Variables ###
variable "access_token" {}
variable "realm" {}
variable "metrics_url" {}
variable "metrics_tracing" {}
variable "apm_environment" {}

### Function Names ###
variable "function_retailorderprice_name" {}

### Function URLs ###
variable "function_retailorderprice_url" {}
