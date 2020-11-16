### AWS Variables  ###

variable "key_name" {
  default = []
}

variable "profile" {
  default = []
}

variable "region" {
  description = "Select region (1:eu-west-1, 2:eu-west-3, 3:us-east-1, 4:us-east-2, 5:us-west-1, 6:us-west-2, 7:ap-southeast-1, 8:ap-southeast-2, 9:sa-east-1 )"
}

variable "aws_region" {
  description = "Provide the desired region"
    default = {
      "1" = "eu-west-1"
      "2" = "eu-west-3"
      "3" = "us-east-1"
      "4" = "us-east-2"
      "5" = "us-west-1"
      "6" = "us-west-2"
      "7" = "ap-southeast-1"
      "8" = "ap-southeast-2"
      "9" = "sa-east-1"
    }
}

variable "region_wrapper_python" {
  default = {
    "1" = "arn:aws:lambda:eu-west-1:254067382080:layer:signalfx-lambda-python-wrapper:11"
    "2" = "arn:aws:lambda:eu-west-3:254067382080:layer:signalfx-lambda-python-wrapper:11"
    "3" = "arn:aws:lambda:us-east-1:254067382080:layer:signalfx-lambda-python-wrapper:11"
    "4" = "arn:aws:lambda:us-east-2:254067382080:layer:signalfx-lambda-python-wrapper:11"
    "5" = "arn:aws:lambda:us-west-1:254067382080:layer:signalfx-lambda-python-wrapper:11"
    "6" = "arn:aws:lambda:us-west-2:254067382080:layer:signalfx-lambda-python-wrapper:11"
    "7" = "arn:aws:lambda:ap-southeast-1:254067382080:layer:signalfx-lambda-python-wrapper:11"
    "8" = "arn:aws:lambda:ap-southeast-2:254067382080:layer:signalfx-lambda-python-wrapper:11"
    "9" = "arn:aws:lambda:sa-east-1:254067382080:layer:signalfx-lambda-python-wrapper:11"  
  }
}

variable "region_wrapper_nodejs" {
  default = {
    "1" = "arn:aws:lambda:eu-west-1:254067382080:layer:signalfx-lambda-nodejs-wrapper:17"
    "2" = "arn:aws:lambda:eu-west-3:254067382080:layer:signalfx-lambda-nodejs-wrapper:17"
    "3" = "arn:aws:lambda:us-east-1:254067382080:layer:signalfx-lambda-nodejs-wrapper:18"
    "4" = "arn:aws:lambda:us-east-2:254067382080:layer:signalfx-lambda-nodejs-wrapper:18"
    "5" = "arn:aws:lambda:us-west-1:254067382080:layer:signalfx-lambda-nodejs-wrapper:18"
    "6" = "arn:aws:lambda:us-west-2:254067382080:layer:signalfx-lambda-nodejs-wrapper:18"
    "7" = "arn:aws:lambda:ap-southeast-1:254067382080:layer:signalfx-lambda-nodejs-wrapper:17"
    "8" = "arn:aws:lambda:ap-southeast-2:254067382080:layer:signalfx-lambda-nodejs-wrapper:17"
    "9" = "arn:aws:lambda:sa-east-1:254067382080:layer:signalfx-lambda-nodejs-wrapper:17"  
  }
}

variable "lambda_initiate_lambda_role_arn" {
  default = []
}

variable "function_ids" {
  type = list(string)
  default = []
}

variable "function_count" {
  default = {}
}

### SFx Variables ###
variable "access_token" {
  default = []
}

variable "realm" {
  default = []
}

variable "metrics_url" {
  default = []
}

variable "metrics_tracing" {
  default = []
}

variable "apm_environment" {
  default = []
}

### Function URLs ###

variable "function_example_url" {
  default = "https://raw.githubusercontent.com/geoffhigginbottom/lambda_functions/main/example/main.js"
}

variable "function_retailorder_url" {
  default = "https://raw.githubusercontent.com/geoffhigginbottom/lambda_functions/main/RetailOrder/Lambda_Function.py"
}

variable "function_retailorderline_url" {
  default = "https://raw.githubusercontent.com/geoffhigginbottom/lambda_functions/main/RetailOrderLine/Lambda_Function.py"
}

variable "function_retailorderprice_url" {
  default = "https://raw.githubusercontent.com/geoffhigginbottom/lambda_functions/main/RetailOrderPrice/index.js"
}

variable "function_retaildiscount_url" {
  default = "https://raw.githubusercontent.com/geoffhigginbottom/lambda_functions/main/RetailDiscount/index.js"
}
