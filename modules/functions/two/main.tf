resource "null_resource" "lambda_function_file" {
  provisioner "local-exec" {
    command = "curl -o ${path.module}/lambda_function.py ${var.function_two_url}"
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

resource "aws_lambda_function" "two" {
  filename      = "./modules/functions/two/lambda.zip"
  function_name = var.function_two_name
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

output "lambda_function_two_arn" {
  value = aws_lambda_function.two.arn
}
