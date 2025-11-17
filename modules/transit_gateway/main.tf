resource "aws_ec2_transit_gateway" "main" {
  description                     = var.description
  amazon_side_asn                = var.amazon_side_asn
  auto_accept_shared_attachments = var.auto_accept_shared_attachments
  default_route_table_association = var.default_route_table_association
  default_route_table_propagation = var.default_route_table_propagation
  dns_support                    = var.dns_support
  vpn_ecmp_support               = var.vpn_ecmp_support

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-tgw"
    }
  )
}

resource "aws_ec2_transit_gateway_vpc_attachment" "main" {
  for_each = var.vpc_attachments

  subnet_ids                                      = each.value.subnet_ids
  transit_gateway_id                              = aws_ec2_transit_gateway.main.id
  vpc_id                                          = each.value.vpc_id
  appliance_mode_support                          = lookup(each.value, "appliance_mode_support", "disable")
  dns_support                                     = lookup(each.value, "dns_support", "enable")
  ipv6_support                                    = lookup(each.value, "ipv6_support", "disable")
  transit_gateway_default_route_table_association = lookup(each.value, "transit_gateway_default_route_table_association", true)
  transit_gateway_default_route_table_propagation = lookup(each.value, "transit_gateway_default_route_table_propagation", true)

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-tgw-attachment-${each.key}"
    }
  )
}

