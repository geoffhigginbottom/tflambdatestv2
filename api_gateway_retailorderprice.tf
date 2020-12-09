### API Gateway ###
resource "aws_api_gateway_rest_api" "retailorderprice" {
  count       = var.function_count
  name        = "${element(var.function_ids, count.index)}_RetailOrderPrice_api_gateway"
}

# ### Debugging Outputs
# output "retailorderprice_invoke_url" {
#   value =  formatlist(
#     "%s, %s", 
#     aws_api_gateway_rest_api.retailorderprice.*.name,
#     aws_api_gateway_deployment.retailorderprice.*.invoke_url
#   )
# }
