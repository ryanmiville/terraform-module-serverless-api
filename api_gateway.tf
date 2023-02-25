data "template_file" "open_api" {
  template = var.openapi_template
  vars     = { "lambda_invoke_arn" = aws_lambda_function.lambda.invoke_arn }
}

resource "aws_api_gateway_rest_api" "rest_api" {
  name        = local.name
  description = var.description
  body        = data.template_file.open_api.rendered
  # put_rest_api_mode = "merge" docs say we should do this but tf says it doesn't know what it is.

  endpoint_configuration {
    types            = var.endpoint_configuration.types
    vpc_endpoint_ids = var.endpoint_configuration.vpc_endpoint_ids
  }
}

resource "aws_api_gateway_rest_api_policy" "policy" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Deny",
            "Principal": "*",
            "Action": "execute-api:Invoke",
            "Resource": [
                "execute-api:/*/*"
            ],
            "Condition" : {
                "StringNotEquals": {
                    "aws:SourceVpce": ${jsonencode(var.endpoint_configuration.vpc_endpoint_ids)}
                }
            }
        },
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "execute-api:Invoke",
            "Resource": "execute-api:/*/*"
        }
    ]
  }
  EOF
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  stage_name    = var.name
}

# On first apply, we get a failure:
#
# Error creating API Gateway Deployment: BadRequestException: Private REST API
# doesn't have a resource policy attached to it
#
# It succeeds on rerun. I think we need to add something to the triggers
# or add a `depends_on`, but regardless, once the deployment is initially
# created, we don't see the error again.
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id

  triggers = {
    redeployment = sha1(yamlencode(aws_api_gateway_rest_api.rest_api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lambda_permission" "invoke_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the specified API Gateway.
  source_arn = "${aws_api_gateway_rest_api.rest_api.execution_arn}/*/*"
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.name}"
  retention_in_days = 7
  lifecycle {
    prevent_destroy = false
  }
}
