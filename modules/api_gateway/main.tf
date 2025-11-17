resource "aws_api_gateway_rest_api" "main" {
  name        = "${var.name_prefix}-api"
  description = var.description

  endpoint_configuration {
    types = [var.endpoint_type]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-api"
    }
  )
}

resource "aws_api_gateway_resource" "main" {
  for_each = var.resources

  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = each.value.parent_id == "ROOT" ? aws_api_gateway_rest_api.main.root_resource_id : each.value.parent_id
  path_part   = each.value.path_part
}

resource "aws_api_gateway_method" "main" {
  for_each = var.methods

  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = lookup(aws_api_gateway_resource.main, each.value.resource_id, null) != null ? aws_api_gateway_resource.main[each.value.resource_id].id : each.value.resource_id
  http_method   = each.value.http_method
  authorization = lookup(each.value, "authorization", "NONE")
  authorizer_id = lookup(each.value, "authorizer_id", null)
}

resource "aws_api_gateway_integration" "main" {
  for_each = var.integrations

  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = lookup(aws_api_gateway_resource.main, each.value.resource_id, null) != null ? aws_api_gateway_resource.main[each.value.resource_id].id : each.value.resource_id
  http_method = aws_api_gateway_method.main[each.key].http_method

  type                    = each.value.integration_type
  integration_http_method = lookup(each.value, "integration_http_method", null)
  uri                     = lookup(each.value, "uri", null)
  connection_type         = lookup(each.value, "connection_type", null)
  connection_id           = lookup(each.value, "connection_id", null)
}

resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.main,
      aws_api_gateway_method.main,
      aws_api_gateway_integration.main,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = var.stage_name

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-api-stage"
    }
  )
}

