### API Gateway ###
## Name has the same random string appended to it as applied
## to the name of the associated function.
resource "aws_api_gateway_rest_api" "example" {
  name        = "${var.function_example_name}_${random_id.example.hex}_api_gateway"
}