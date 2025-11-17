resource "aws_vpn_gateway" "main" {
  count = var.create_vpn_gateway ? 1 : 0

  vpc_id            = var.vpc_id
  amazon_side_asn   = var.amazon_side_asn

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-vpn-gateway"
    }
  )
}

resource "aws_vpn_gateway_attachment" "main" {
  count = var.create_vpn_gateway ? 1 : 0

  vpc_id         = var.vpc_id
  vpn_gateway_id = aws_vpn_gateway.main[0].id
}

resource "aws_customer_gateway" "main" {
  for_each = var.customer_gateways

  bgp_asn    = each.value.bgp_asn
  ip_address = each.value.ip_address
  type       = each.value.type

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-cgw-${each.key}"
    }
  )
}

resource "aws_vpn_connection" "main" {
  for_each = var.create_vpn_gateway ? var.customer_gateways : {}

  vpn_gateway_id      = aws_vpn_gateway.main[0].id
  customer_gateway_id = aws_customer_gateway.main[each.key].id
  type                = aws_customer_gateway.main[each.key].type
  static_routes_only  = lookup(each.value, "static_routes_only", false)

  dynamic "static_routes" {
    for_each = lookup(each.value, "static_routes", [])
    content {
      destination_cidr_block = static_routes.value
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-vpn-connection-${each.key}"
    }
  )
}

resource "aws_vpn_connection_route" "main" {
  for_each = var.create_vpn_gateway ? var.vpn_routes : {}

  destination_cidr_block = each.value.destination_cidr_block
  vpn_connection_id      = aws_vpn_connection.main[each.value.vpn_connection_key].id
}

