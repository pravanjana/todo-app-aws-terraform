output "api_endpoint" {
  value = aws_apigatewayv2_api.todo_api.api_endpoint
}

output "lambda_name" {
  value = aws_lambda_function.todo_lambda.function_name
}

output "dynamodb_table" {
  value = aws_dynamodb_table.todo_table.name
}
