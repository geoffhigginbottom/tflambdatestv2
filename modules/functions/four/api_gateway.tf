### API Gateway ###
## Name has the same random string appended to it as applied
## to the name of the associated function.
resource "aws_api_gateway_rest_api" "four" {
  name        = "${var.function_four_name}_${random_id.four.hex}_api_gateway"
}
