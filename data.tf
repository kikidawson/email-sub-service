data "aws_iam_policy_document" "trust_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/python/subscriber_lambda.py"
  output_path = "${path.module}/python/subscriber_lambda.zip"
}

data "aws_iam_policy_document" "subscriber_lambda_role" {
  statement {
    sid       = "AllowLambdaToUpdateTable"
    resources = [aws_dynamodb_table.subscribers.stream_arn]

    actions = [
      "dynamodb:GetRecords",
      "dynamodb:GetShardIterator",
      "dynamodb:DescribeStream",
      "dynamodb:ListStreams",
    ]
  }

  statement {
    sid       = "AllowLambdaToSubscribeEmailAddresses"
    resources = [aws_sns_topic.subscribers.arn]
    actions   = ["SNS:Subscribe"]
  }
}
