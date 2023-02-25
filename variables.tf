variable "name" {
  type = string
}

variable "description" {
  type = string
}

variable "environment" {
  type = string
}

variable "filename" {
  type = string
}

variable "function_name" {
  type = string
}

variable "handler" {
  type = string
}
variable "iam_policy" {
  
}

variable "runtime" {
  type = string
}

variable "source_code_hash" {
  type = string
}

variable "timeout" {
}

variable "openapi_template" {
  type = string
}

variable "health_check" {
  type = string
}

variable "vpc_config" {
}

variable "endpoint_configuration" {
}

variable "environment_variables" {
  type = map(string)
}
