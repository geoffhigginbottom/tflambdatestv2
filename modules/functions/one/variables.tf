### AWS Variables ###
variable "region" {}
variable "region_wrapper" {}

variable "lambda_initiate_lambda_role_arn" {
    type = string
}

variable "lambda_function_two_arn"{
    type = string
}

### SFx Variables ###
variable "access_token" {}
variable "realm" {}
variable "metrics_url" {}
variable "metrics_tracing" {}
variable "apm_environment" {}

### Function Names ###
variable "function_one_name" {}

### Function URLs ###
variable "function_one_url" {}
