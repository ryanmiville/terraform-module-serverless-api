resource "aws_lambda_function" "lambda" {
  filename         = var.filename
  function_name    = local.function_name
  handler          = var.handler
  role             = aws_iam_role.lambda_role.arn
  runtime          = var.runtime
  architectures     = ["x86_64"]
  layers           = ["arn:aws:lambda:us-east-1:753240598075:layer:LambdaAdapterLayerX86:11"]
  source_code_hash = var.source_code_hash
  timeout          = var.timeout

  environment {
    variables = merge(
      {
        AWS_LAMBDA_EXEC_WRAPPER = "/opt/bootstrap"
        READINESS_CHECK_PATH    = var.health_check
      },
    var.environment_variables)
  }

  vpc_config {
    subnet_ids         = var.vpc_config.subnet_ids
    security_group_ids = var.vpc_config.security_group_ids
  }
}
