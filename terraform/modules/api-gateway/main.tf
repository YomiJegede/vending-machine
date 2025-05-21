resource "aws_api_gateway_rest_api" "api" {
  name        = "${var.env_prefix}-api"
  description = "API Gateway for ${var.env_prefix}"
}

resource "aws_api_gateway_resource" "public" {
  count       = length(var.public_route_paths)
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = trimprefix(var.public_route_paths[count.index], "/")
}

resource "aws_api_gateway_resource" "private" {
  count       = length(var.private_route_paths)
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = trimprefix(var.private_route_paths[count.index], "/")
}

resource "aws_api_gateway_method" "public" {
  count         = length(var.public_route_paths)
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.public[count.index].id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "private" {
  count         = length(var.private_route_paths)
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.private[count.index].id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "public" {
  count                   = length(var.public_route_paths)
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.public[count.index].id
  http_method             = aws_api_gateway_method.public[count.index].http_method
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.alb_dns_name}/beverages" 
 
}

resource "aws_api_gateway_integration" "private" {
  count                   = length(var.private_route_paths)
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.private[count.index].id
  http_method             = aws_api_gateway_method.private[count.index].http_method
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  # uri                   = "http://${var.alb_dns_name}${var.private_route_paths[count.index]}"
  uri                     = "http://${var.vpc_link_nlb_dns_name}${var.private_route_paths[count.index]}"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.vpc_link.id
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.public,
    aws_api_gateway_integration.private
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "test"
}

resource "aws_api_gateway_vpc_link" "vpc_link" {
  name        = "${var.env_prefix}-vpc-link"
  target_arns = [var.vpc_link_target_arn]
}