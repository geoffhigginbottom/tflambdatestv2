### API Gateway ###
## Name has the same random string appended to it as applied
## to the name of the associated function.
resource "aws_api_gateway_rest_api" "one" {
  name        = "${var.function_one_name}_${random_id.one.hex}_api_gateway"
}
