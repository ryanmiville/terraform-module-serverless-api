# Terraform Module Serverless API

## Example

```hcl
module "serverless_api" {
  source            = "git@github.com:ryanmiville/terraform-module-serverless-api"
  name              = "my-api"
  description       = "example api"
  environment       = "dev"
  filename          = "lambda.zip"
  function_name     = "my-lambda"
  handler           = "run.sh"
  iam_policy        = data.aws_iam_policy_document.main.json
  runtime           = "nodejs14.x"
  source_code_hash  = filebase64sha256("lambda.zip")
  timeout           = 30
  openapi_template = file("openapi.yaml")
  health_check      = "/health"

  vpc_config = {
    subnet_ids         = local.subnet_ids
    security_group_ids = local.security_group_ids
  }

  endpoint_configuration = {
    types            = ["PRIVATE"]
    vpc_endpoint_ids = local.vpc_endpoint_ids
  }

  environment_variables = {
    PGDATABASE              = "myapp"
    PGHOST                  = data.vault_generic_secret.db.data["ro_hostname"]
    PGPORT                  = data.vault_generic_secret.db.data["port"]
    PGUSER                  = "myuser"
  }
  
}
```
