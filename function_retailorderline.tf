### Lambda Function Code
## Terafrom generates the lambda function from a zip file which is pulled down 
## from a separate repo defined in varibales.tf in root folder
resource "null_resource" "retailorderline_lambda_function_file" {
  provisioner "local-exec" {
    command = "curl -o retailorderline_lambda_function.py ${var.function_retailorderline_url}"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "rm retailorderline_lambda_function.py && rm retailorderline_lambda.zip"
  }
}

data "archive_file" "retailorderline_lambda_zip" {
  type        = "zip"
  source_file  = "retailorderline_lambda_function.py"
  output_path = "retailorderline_lambda.zip"
  depends_on = [null_resource.retailorderline_lambda_function_file]
}

### Create Lambda Function ###
resource "aws_lambda_function" "retailorderline" {
  count         = var.function_count
  filename      = "retailorderline_lambda.zip"
  # function_name = var.function_retailorderline_name
  function_name = "RetailOrderLine_${element(var.function_ids, count.index)}"
  role          = aws_iam_role.lambda_role.arn
  handler       = "retailorderline_lambda_function.lambda_handler"
  layers        = [lookup(var.region_wrapper_python, var.region), aws_lambda_layer_version.request-opentracing_2_0.arn ]
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

# ### Debugging Outputs
# output "retailorderline_arns" {
#   value =  formatlist(
#     "%s, %s", 
#     aws_lambda_function.retailorderline.*.function_name,
#     aws_lambda_function.retailorderline.*.arn
#   )
# }
