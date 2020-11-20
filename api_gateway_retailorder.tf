### API Gateway ###
resource "aws_api_gateway_rest_api" "retailorder" {
  count       = var.function_count
  name        = "RetailOrder_${element(var.function_ids, count.index)}_api_gateway"
}
