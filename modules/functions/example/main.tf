### Generate Randowm ID ###
## Random ID will be used to make the name of the function
## and the API Gateway unique to allow multiple deployments 
## within the same AWS Account.
## Functions and their associated API Gateways will use the same string
resource "random_id" "example" {
  byte_length = 4
}

### Output Random ID ###
## Output the value so it can be used by api_gateway.tf
output "random_id_example" {
  value = random_id.example.hex
}

### Lambda Function Code
## Terafrom generates the lambda function from a zip file which is pulled down 
## from a separate repo defined in varibales.tf in root folder
resource "null_resource" "lambda_function_file" {
  provisioner "local-exec" {
    command = "curl -o ${path.module}/main.js ${var.function_example_url}"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "rm ${path.module}/main.js && rm ${path.module}/lambda.zip"
  }
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file  = "${path.module}/main.js"
  output_path = "${path.module}/lambda.zip"
  depends_on = [null_resource.lambda_function_file]
}

### Create Lambda Function ###
## Creates the lambda function from the example.zip
## All vars are stored in variables.tf in root folder, and linked via local variables.tf
## Role is defined in the iam module
## The runtime and timeout values are defined here, but could also be set as vars
resource "aws_lambda_function" "example" {
  filename      = "./modules/functions/example/lambda.zip"
  function_name = "${var.function_example_name}_${random_id.example.hex}"
  role          = var.lambda_initiate_lambda_role_arn
  handler       = "main.handler"
  layers        = [lookup(var.region_wrapper, var.region)]
  runtime       = "nodejs10.x"
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

### API Gateway Proxy ###
## Imports id's from the API gateway created by api_gateway.tf
## The special path_part value "{proxy+}" activates proxy behavior, 
## which means that this resource will match any request path
resource "aws_api_gateway_resource" "proxy" {
   rest_api_id = aws_api_gateway_rest_api.example.id
   parent_id   = aws_api_gateway_rest_api.example.root_resource_id
   path_part   = "{proxy+}"
}

### API Gateway Method ###
## Uses a http_method of "ANY", which allows any request method to be used.
## Working in conjunction with the proxy+ setting above means that all 
## incoming requests will match this resource
resource "aws_api_gateway_method" "proxy" {
   rest_api_id   = aws_api_gateway_rest_api.example.id
   resource_id   = aws_api_gateway_resource.proxy.id
   http_method   = "ANY"
   authorization = "NONE"
}

### API Routing to Lambda ###
## Specifes that requests to method are sent to the Lambda Function
resource "aws_api_gateway_integration" "lambda" {
   rest_api_id = aws_api_gateway_rest_api.example.id
   resource_id = aws_api_gateway_method.proxy.resource_id
   http_method = aws_api_gateway_method.proxy.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.example.invoke_arn
}

### API Routing for proxy_root###
## The AWS_PROXY integration type causes API gateway to call into the API of another AWS service.
## In this case, it will call the AWS Lambda API to create an "invocation" of the Lambda function.
## Unfortunately the proxy resource cannot match an empty path at the root of the API. 
## To handle that, a similar configuration must be applied to the root resource that is built in to the REST API object:
resource "aws_api_gateway_method" "proxy_root" {
   rest_api_id   = aws_api_gateway_rest_api.example.id
   resource_id   = aws_api_gateway_rest_api.example.root_resource_id
   http_method   = "ANY"
   authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
   rest_api_id = aws_api_gateway_rest_api.example.id
   resource_id = aws_api_gateway_method.proxy_root.resource_id
   http_method = aws_api_gateway_method.proxy_root.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.example.invoke_arn
}

### Activate and expose API Gateway ###
## Create an API Gateway "deployment" in order to activate the configuration and 
## expose the API at a URL that can be used for testing.
resource "aws_api_gateway_deployment" "example" {
   depends_on = [
     aws_api_gateway_integration.lambda,
     aws_api_gateway_integration.lambda_root,
   ]

   rest_api_id = aws_api_gateway_rest_api.example.id
   stage_name  = "test"
}

### Grant Lambda Access to API Gateway ###
## By default any two AWS services have no access to one another, 
## until access is explicitly granted.
resource "aws_lambda_permission" "apigw" {
   statement_id  = "AllowAPIGatewayInvoke"
   action        = "lambda:InvokeFunction"
   function_name = aws_lambda_function.example.function_name
   principal     = "apigateway.amazonaws.com"

   # The "/*/*" portion grants access from any method on any resource
   # within the API Gateway REST API.
   source_arn = "${aws_api_gateway_rest_api.example.execution_arn}/*/*"
}

### Output test URL ###
## Create a var containing the url and output it to root module
output "base_url" {
  value = aws_api_gateway_deployment.example.invoke_url
}