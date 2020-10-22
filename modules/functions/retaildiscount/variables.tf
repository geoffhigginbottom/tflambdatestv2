### AWS Variables ###
variable "region" {}
variable "region_wrapper" {}

variable "lambda_initiate_lambda_role_arn" {
    type = string
}

variable "invoke_url_tmp" {
    type = string
}

### SFx Variables ###
variable "access_token" {}
variable "realm" {}
variable "metrics_url" {}
variable "metrics_tracing" {}
variable "apm_environment" {}

### Function Names ###
variable "function_retaildiscount_name" {}

### Function URLs ###
variable "function_retaildiscount_url" {}
