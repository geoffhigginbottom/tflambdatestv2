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

variable "region_wrapper" {
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


### Function Names ###
variable "function_example_name" {
  default = "ServerlessExample"
}

variable "function_retailorder_name" {
  default = "Retail_Order"
}

variable "function_retailorderline_name" {
  default = "Retail_Order_Line"
}

variable "function_retailorderprice_name" {
  default = "Retail_Order_Price"
}

variable "function_retaildiscount_name" {
  default = "Retail_Discount"
}

# variable "function_xxx_name" {
#   default = "xxx"
# }

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

# variable "function_xxx_url" {
#   default = "xxx"
# }
