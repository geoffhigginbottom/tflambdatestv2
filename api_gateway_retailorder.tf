### API Gateway ###
resource "aws_api_gateway_rest_api" "retailorder" {
  count       = var.function_count
  name        = "RetailOrder_${element(var.function_ids, count.index)}_api_gateway"
}

### Debugging Outputs
output "retailorder_invoke_url" {
  value =  formatlist(
    "%s, %s", 
    aws_api_gateway_rest_api.retailorder.*.name,
    aws_api_gateway_deployment.retailorder.*.invoke_url
  )
}

# resource "aws_ssm_parameter" "retailorder_invoke_url" {
#   count = var.function_count
#   name  = "retailorder_invoke_url_${element(var.function_ids, count.index)}"
#   type  = "String"
#   value = aws_api_gateway_deployment.retailorder[count.index].invoke_url
#   overwrite = true
# }

# ### Debugging Outputs
# output "retailorder_invoke_url" {
#   value =  formatlist(
#     "%s, %s", 
#     aws_api_gateway_rest_api.retailorder.*.name,
#     aws_ssm_parameter.retailorder_invoke_url.*.value
#   )
# }