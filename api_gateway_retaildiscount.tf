### API Gateway ###
## Name has the same string appended to it as applied
## to the name of the associated function.
resource "aws_api_gateway_rest_api" "retaildiscount" {
  count       = var.function_count
  name        = "Retail_Discount_${element(var.function_ids, count.index)}_api_gateway"
}

### Trim the https:// and /default/ from the api invoke url and store in aws_ssm
### so we can retrieve it within function_retailorderprice and set as a global var.
### Using ssm_paramater as we are using count so cannot use outputs
resource "aws_ssm_parameter" "invoke_urls" {
  count = var.function_count
  name  = "invoke_url_${element(var.function_ids, count.index)}"
  type  = "String"
  value = trimsuffix(trimprefix(aws_api_gateway_deployment.retaildiscount[count.index].invoke_url, "https://"), "/default")
}

# ### Debugging Outputs
# output "retaildiscount_invoke_urls" {
#   value =  formatlist(
#     "%s, %s", 
#     aws_api_gateway_rest_api.retaildiscount.*.name,
#     aws_ssm_parameter.invoke_urls.*.value
#   )
# }
