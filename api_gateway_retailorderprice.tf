### API Gateway ###
resource "aws_api_gateway_rest_api" "retailorderprice" {
  count       = var.function_count
  name        = "${element(var.function_ids, count.index)}_RetailOrderPrice_api_gateway"
}

### Debugging Outputs
output "retailorderprice_invoke_url" {
  value =  formatlist(
    "%s, %s", 
    aws_api_gateway_rest_api.retailorderprice.*.name,
    aws_api_gateway_deployment.retailorderprice.*.invoke_url
  )
}


# ### Append name of RetailOrderPrice function name to the invoke url and store in aws_ssm
# ### so we can retrieve it within function_retailorder.
# ### Using ssm_paramater as we are using count so cannot use outputs.
# resource "aws_ssm_parameter" "retailorderprice_invoke_url" {
#   count = var.function_count
#   name  = "retailorderprice_invoke_url_${element(var.function_ids, count.index)}"
#   type  = "String"
#   value = join("/",[aws_api_gateway_deployment.retailorderprice[count.index].invoke_url, aws_lambda_function.retailorderprice[count.index].function_name])
#   overwrite = true
# }

# ### Debugging Outputs
# output "retailorderprice_invoke_url" {
#   value =  formatlist(
#     "%s, %s", 
#     aws_api_gateway_rest_api.retailorderprice.*.name,
#     aws_ssm_parameter.retailorderprice_invoke_url.*.value
#   )
# }