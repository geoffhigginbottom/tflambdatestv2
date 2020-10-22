### API Gateway ###
## Name has the same random string appended to it as applied
## to the name of the associated function.
resource "aws_api_gateway_rest_api" "retaildiscount" {
  name        = "${var.function_retaildiscount_name}_${random_id.retaildiscount.hex}_api_gateway"
}
