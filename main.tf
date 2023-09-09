resource "aws_dynamodb_table" "subscribers" {
  name             = "ess-subscribers"
  billing_mode     = "PROVISIONED"
  read_capacity    = 20
  write_capacity   = 20
  hash_key         = "email"
  stream_view_type = "NEW_AND_OLD_IMAGES"
  stream_enabled   = true

  attribute {
    name = "email"
    type = "S"
  }

  tags = {
    Name = "ess-subscribers"
  }
}

resource "aws_iam_role" "subscriber_lambda" {
  name               = "ess-subscriber-lambda"
  assume_role_policy = data.aws_iam_policy_document.trust_policy.json
}

resource "aws_iam_policy" "subscriber_lambda" {
  name        = "ess-subscriber-lambda"
  path        = "/"
  description = "Policy to allow lambda read access to subscribers table."
  policy      = data.aws_iam_policy_document.subscriber_lambda_role.json
}

resource "aws_iam_policy_attachment" "subscriber_lambda" {
  name       = "ess-subscriber-lambda"
  roles      = [aws_iam_role.subscriber_lambda.name]
  policy_arn = aws_iam_policy.subscriber_lambda.arn
}

resource "aws_lambda_function" "subscriber" {
  function_name = "ess-subscriber"
  description   = "This lambda subscribes email address to an SNS topic."
  filename      = "${path.module}/python/subscriber_lambda.zip"
  handler       = "subscriber_lambda.handler"
  role          = aws_iam_role.subscriber_lambda.arn
  runtime       = "python3.11"
}

resource "aws_cloudwatch_log_group" "subscriber_lambda" {
  name              = "/aws/lambda/ess-subscriber"
  retention_in_days = 30

  tags = {
    Name = "ess-subscriber"
  }
}

resource "aws_lambda_permission" "subscribers_table" {
  statement_id  = "AllowSubscribersTableToTriggerLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.subscriber.function_name
  principal     = "dynamodb.amazonaws.com"
  source_arn    = aws_dynamodb_table.subscribers.stream_arn
}

resource "aws_lambda_event_source_mapping" "subscribers_table" {
  event_source_arn  = aws_dynamodb_table.subscribers.stream_arn
  function_name     = aws_lambda_function.subscriber.arn
  starting_position = "LATEST"
}
