resource "aws_dx_gateway" "main" {
  name            = "${var.name_prefix}-dx-gateway"
  amazon_side_asn = var.amazon_side_asn

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-dx-gateway"
    }
  )
}

resource "aws_dx_gateway_association" "main" {
  dx_gateway_id         = aws_dx_gateway.main.id
  associated_gateway_id = var.transit_gateway_id != null ? var.transit_gateway_id : var.vpn_gateway_id

  allowed_prefixes = var.allowed_prefixes
}

resource "aws_dx_connection" "main" {
  count = var.create_connection ? 1 : 0

  name      = "${var.name_prefix}-dx-connection"
  bandwidth = var.bandwidth
  location  = var.location

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-dx-connection"
    }
  )
}

resource "aws_dx_lag" "main" {
  count = var.create_lag ? 1 : 0

  name                  = "${var.name_prefix}-dx-lag"
  connections_bandwidth = var.bandwidth
  location              = var.location
  number_of_connections = var.number_of_connections

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-dx-lag"
    }
  )
}

