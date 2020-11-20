### API Gateway ###
resource "aws_api_gateway_rest_api" "retailorderdiscount" {
  count       = var.function_count
  name        = "RetailOrderDiscount_${element(var.function_ids, count.index)}_api_gateway"
}

### Trim the https:// and /default from the api invoke url and store in aws_ssm
### so we can retrieve it within function_retailorderprice.
### Using ssm_paramater as we are using count so cannot use outputs
resource "aws_ssm_parameter" "retaildiscount_invoke_url" {
  count = var.function_count
  name  = "retaildiscount_invoke_url_${element(var.function_ids, count.index)}"
  type  = "String"
  value = trimsuffix(trimprefix(aws_api_gateway_deployment.retailorderdiscount[count.index].invoke_url, "https://"), "/default")
  overwrite = true
}

### Debugging Outputs
output "retaildiscount_invoke_url" {
  value =  formatlist(
    "%s, %s", 
    aws_api_gateway_rest_api.retailorderdiscount.*.name,
    aws_ssm_parameter.retaildiscount_invoke_url.*.value
  )
}
