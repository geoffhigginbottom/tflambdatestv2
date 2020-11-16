### API Gateway ###
## Name has the same string appended to it as applied
## to the name of the associated function.
resource "aws_api_gateway_rest_api" "retailorder" {
  count       = var.function_count
  name        = "Retail_Order_${element(var.function_ids, count.index)}_api_gateway"
}
