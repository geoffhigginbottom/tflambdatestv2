### API Gateway ###
## Name has the same random string appended to it as applied
## to the name of the associated function.
resource "aws_api_gateway_rest_api" "retailorderprice" {
  name        = "${var.function_retailorderprice_name}_${random_id.retailorderprice.hex}_api_gateway"
}
