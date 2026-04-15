# DynamoDB Table
resource "aws_dynamodb_table" "todo_table" {
  name         = "todo-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "todo-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "dynamodb_access" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

# Lambda Function
resource "aws_lambda_function" "todo_lambda" {
  function_name = "todo-lambda"
  filename      = "../lambda/todohandler.zip"
  handler       = "todohandler.lambda_handler"
  runtime       = "python3.11"
  role          = aws_iam_role.lambda_role.arn
  architectures = ["x86_64"]

  source_code_hash = filebase64sha256("../lambda/todohandler.zip")

  environment {
    variables = {
      TODO_TABLE = aws_dynamodb_table.todo_table.name
    }
  }
}

# API Gateway HTTP API
resource "aws_apigatewayv2_api" "todo_api" {
  name          = "todo-api"
  protocol_type = "HTTP"


 cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "DELETE", "PUT", "OPTIONS"]
    allow_headers = ["content-type"]
  }
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                  = aws_apigatewayv2_api.todo_api.id
  integration_type        = "AWS_PROXY"
  integration_uri         = aws_lambda_function.todo_lambda.invoke_arn
  payload_format_version  = "2.0"
}

resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.todo_api.id
  route_key = "ANY /tasks"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.todo_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.todo_lambda.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_apigatewayv2_route" "delete_task_route" {
  api_id    = aws_apigatewayv2_api.todo_api.id
  route_key = "DELETE /tasks/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "update_task_route" {
  api_id    = aws_apigatewayv2_api.todo_api.id
  route_key = "PUT /tasks/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}
