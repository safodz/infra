data "archive_file" "lambda_zip" {
  count = var.create_zip ? 1 : 0

  type        = "zip"
  source_file = var.source_file
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "main" {
  function_name = "${var.name_prefix}-function"
  role          = aws_iam_role.lambda.arn
  handler       = var.handler
  runtime       = var.runtime
  timeout       = var.timeout
  memory_size   = var.memory_size

  filename         = var.create_zip ? data.archive_file.lambda_zip[0].output_path : var.filename
  source_code_hash = var.create_zip ? data.archive_file.lambda_zip[0].output_base64sha256 : filebase64sha256(var.filename)

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  environment {
    variables = var.environment_variables
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-function"
    }
  )
}

resource "aws_iam_role" "lambda" {
  name = "${var.name_prefix}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-lambda-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  count = length(var.subnet_ids) > 0 ? 1 : 0

  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "lambda" {
  name = "${var.name_prefix}-lambda-policy"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = var.iam_policy_statements
  })
}

resource "aws_lambda_permission" "api_gateway" {
  count = var.api_gateway_source_arn != null ? 1 : 0

  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_gateway_source_arn}/*/*"
}

resource "aws_lambda_permission" "dynamodb" {
  count = var.dynamodb_stream_arn != null ? 1 : 0

  statement_id  = "AllowExecutionFromDynamoDB"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal     = "dynamodb.amazonaws.com"
  source_arn    = var.dynamodb_stream_arn
}

resource "aws_lambda_event_source_mapping" "dynamodb" {
  count = var.dynamodb_stream_arn != null ? 1 : 0

  event_source_arn  = var.dynamodb_stream_arn
  function_name     = aws_lambda_function.main.arn
  starting_position = "LATEST"
  batch_size        = var.dynamodb_batch_size
}
