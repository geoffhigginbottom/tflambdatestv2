### API Gateway ###
## Name has the same random string appended to it as applied
## to the name of the associated function.
resource "aws_api_gateway_rest_api" "retailorder" {
  name        = "${var.function_retailorder_name}_${random_id.retailorder.hex}_api_gateway"
}
