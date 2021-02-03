### AWS Variables  ###

variable "key_name" {
  default = []
}

variable "private_key_path"{
  default = []
}

variable "instance_type" {
  default = []
}

variable "profile" {
  default = []
}

variable "region" {
  description = "Select region (1:eu-west-1, 2:eu-west-3, 3:eu-central-1, 4:us-east-1, 5:us-east-2, 6:us-west-1, 7:us-west-2, 8:ap-southeast-1, 9:ap-southeast-2, 10:sa-east-1 )"
}

variable "function_timeout" {
  default = 15
}

variable "aws_region" {
  description = "Provide the desired region"
    default = {
      "1" = "eu-west-1"
      "2" = "eu-west-3"
      "3" = "eu-central-1"
      "4" = "us-east-1"
      "5" = "us-east-2"
      "6" = "us-west-1"
      "7" = "us-west-2"
      "8" = "ap-southeast-1"
      "9" = "ap-southeast-2"
      "10" = "sa-east-1"
    }
}

## List available at https://github.com/signalfx/lambda-layer-versions/blob/master/python/PYTHON.md ##
variable "region_wrapper_python" {
  default = {
    "1" = "arn:aws:lambda:eu-west-1:254067382080:layer:signalfx-lambda-python-wrapper:11"
    "2" = "arn:aws:lambda:eu-west-3:254067382080:layer:signalfx-lambda-python-wrapper:11"
    "3" = "arn:aws:lambda:eu-central-1:254067382080:layer:signalfx-lambda-python-wrapper:11"
    "4" = "arn:aws:lambda:us-east-1:254067382080:layer:signalfx-lambda-python-wrapper:11"
    "5" = "arn:aws:lambda:us-east-2:254067382080:layer:signalfx-lambda-python-wrapper:11"
    "6" = "arn:aws:lambda:us-west-1:254067382080:layer:signalfx-lambda-python-wrapper:11"
    "7" = "arn:aws:lambda:us-west-2:254067382080:layer:signalfx-lambda-python-wrapper:11"
    "8" = "arn:aws:lambda:ap-southeast-1:254067382080:layer:signalfx-lambda-python-wrapper:11"
    "9" = "arn:aws:lambda:ap-southeast-2:254067382080:layer:signalfx-lambda-python-wrapper:11"
    "10" = "arn:aws:lambda:sa-east-1:254067382080:layer:signalfx-lambda-python-wrapper:11"  
  }
}

## List available at https://github.com/signalfx/lambda-layer-versions/blob/master/node/NODE.md ##
variable "region_wrapper_nodejs" {
  default = {
    "1" = "arn:aws:lambda:eu-west-1:254067382080:layer:signalfx-lambda-nodejs-wrapper:18"
    "2" = "arn:aws:lambda:eu-west-3:254067382080:layer:signalfx-lambda-nodejs-wrapper:18"
    "3" = "arn:aws:lambda:eu-central-1:254067382080:layer:signalfx-lambda-nodejs-wrapper:19"
    "4" = "arn:aws:lambda:us-east-1:254067382080:layer:signalfx-lambda-nodejs-wrapper:18"
    "5" = "arn:aws:lambda:us-east-2:254067382080:layer:signalfx-lambda-nodejs-wrapper:18"
    "6" = "arn:aws:lambda:us-west-1:254067382080:layer:signalfx-lambda-nodejs-wrapper:18"
    "7" = "arn:aws:lambda:us-west-2:254067382080:layer:signalfx-lambda-nodejs-wrapper:18"
    "8" = "arn:aws:lambda:ap-southeast-1:254067382080:layer:signalfx-lambda-nodejs-wrapper:17"
    "9" = "arn:aws:lambda:ap-southeast-2:254067382080:layer:signalfx-lambda-nodejs-wrapper:17"
    "10" = "arn:aws:lambda:sa-east-1:254067382080:layer:signalfx-lambda-nodejs-wrapper:17"  
  }
}

## Select beteen APM and Base version of the Functions
variable "function_version" {
  description = "Select Function Version (a:apm, b:base)"
}

variable "function_version_function_name_suffix" {
  default = {
    "a" = "apm"
    "b" = "base"
  }
}

variable "function_version_function_retailorder_url" {
  default = {
    "a" = "https://raw.githubusercontent.com/hagen-p/SplunkLambdaAPM/master/Lambdas/APM/RetailOrderAPM/Lambda_Function.py"
    "b" = "https://raw.githubusercontent.com/hagen-p/SplunkLambdaAPM/master/Lambdas/Base/RetailOrder/Lambda_Function.py"
  }
}

variable "function_version_function_retailorderline_url" {
  default = {
    "a" = "https://raw.githubusercontent.com/hagen-p/SplunkLambdaAPM/master/Lambdas/APM/RetailOrderLineAPM/Lambda_Function.py"
    "b" = "https://raw.githubusercontent.com/hagen-p/SplunkLambdaAPM/master/Lambdas/Base/RetailOrderLine/Lambda_Function.py"
  }
}

variable "function_version_function_retailorderprice_url" {
  default = {
    "a" = "https://raw.githubusercontent.com/hagen-p/SplunkLambdaAPM/master/Lambdas/APM/RetailOrderPriceAPM/index.js"
    "b" = "https://raw.githubusercontent.com/hagen-p/SplunkLambdaAPM/master/Lambdas/Base/RetailOrderPrice/index.js"
  }
}

variable "function_version_function_retailorderdiscount_url" {
  default = {
    "a" = "https://raw.githubusercontent.com/hagen-p/SplunkLambdaAPM/master/Lambdas/APM/RetailDiscountAPM/index.js"
    "b" = "https://raw.githubusercontent.com/hagen-p/SplunkLambdaAPM/master/Lambdas/Base/RetailDiscount/index.js"
  }
}

## URL for the Java App - pulls it from the listed Git Repo
variable "java_app_url" {
  default = "https://github.com/hagen-p/SplunkLambdaAPM.git"
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


## AMI ##
data "aws_ami" "latest-ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # This is the owner id of Canonical who owns the official aws ubuntu images

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

### SFx Variables ###
variable "access_token" {
  default = []
}

variable "realm" {
  default = []
}

variable "smart_agent_version" {
  default = []
}

variable "environment" {
  default = "Retail_Demo"
}

# variable "collector_config_path" {
#   default = "/tmp/collector.yaml"
# }

### https://quay.io/repository/signalfx/splunk-otel-collector?tab=tags
variable "otelcol_version" {
  default = []
}

variable "ballast" {
  default = []
}
