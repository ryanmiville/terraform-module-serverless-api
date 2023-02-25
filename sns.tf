# Create some SNS topic.
resource "aws_sns_topic" "lambda_sns_topic" {
  name = local.name

}

resource "aws_sns_topic_policy" "lambda_sns_policy" {
  arn = aws_sns_topic.lambda_sns_topic.arn

  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

# Allow the lambda to be invoked by this SNS topic
resource "aws_lambda_permission" "with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.lambda_sns_topic.arn
}

# Create a subscription for the lambda to this Topic
resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = aws_sns_topic.lambda_sns_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.lambda.arn
}

data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.lambda_sns_topic.arn,
    ]
  }
}
