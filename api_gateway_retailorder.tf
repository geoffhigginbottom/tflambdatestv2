### API Gateway ###
resource "aws_api_gateway_rest_api" "retailorder" {
  count       = var.function_count
  name        = "${element(var.function_ids, count.index)}_RetailOrder_api_gateway"
}

# ### Debugging Outputs
# output "retailorder_invoke_url" {
#   value =  formatlist(
#     "%s, %s", 
#     aws_api_gateway_rest_api.retailorder.*.name,
#     aws_api_gateway_deployment.retailorder.*.invoke_url
#   )
# }
