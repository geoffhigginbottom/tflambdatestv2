### Generate Randowm ID ###
## Random ID will be used to make the name of the function
## and the API Gateway unique to allow multiple deployments 
## within the same AWS Account.
## Functions and their associated API Gateways will use the same string
resource "random_id" "retailorderline" {
  byte_length = 4
}

### Output Random ID ###
## Output the value so it can be used by api_gateway.tf
output "random_id_retailorderline" {
  value = random_id.retailorderline.hex
}

### Lambda Function Code
## Terafrom generates the lambda function from a zip file which is pulled down 
## from a separate repo defined in varibales.tf in root folder
resource "null_resource" "lambda_function_file" {
  provisioner "local-exec" {
    command = "curl -o ${path.module}/lambda_function.py ${var.function_retailorderline_url}"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "rm ${path.module}/lambda_function.py && rm ${path.module}/lambda.zip"
  }
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file  = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda.zip"
  depends_on = [null_resource.lambda_function_file]
}

### Create Lambda Function ###
## Creates the lambda function from the example.zip
## All vars are stored in variables.tf in root folder, and linked via local variables.tf
## Role is defined in the iam module
## The runtime and timeout values are defined here, but could also be set as vars
resource "aws_lambda_function" "retailorderline" {
  filename      = "./modules/functions/retailorderline/lambda.zip"
  function_name = "${var.function_retailorderline_name}_${random_id.retailorderline.hex}"
  role          = var.lambda_initiate_lambda_role_arn
  handler       = "lambda_function.lambda_handler"
  layers        = [lookup(var.region_wrapper, var.region)]
  runtime       = "python3.8"
  timeout       = 90

  environment {
    variables = {
      SIGNALFX_ACCESS_TOKEN = var.access_token
      SIGNALFX_APM_ENVIRONMENT = var.apm_environment
      SIGNALFX_METRICS_URL = var.metrics_url
      SIGNALFX_TRACING_URL = var.metrics_tracing
    }
  }
}

output "lambda_function_retailorderline_arn" {
  value = aws_lambda_function.retailorderline.arn
}
