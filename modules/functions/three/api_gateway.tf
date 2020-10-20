### API Gateway ###
## Name has the same random string appended to it as applied
## to the name of the associated function.
resource "aws_api_gateway_rest_api" "three" {
  name        = "${var.function_three_name}_${random_id.three.hex}_api_gateway"
}
