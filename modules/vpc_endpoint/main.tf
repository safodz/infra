resource "aws_vpc_endpoint" "main" {
  for_each = var.endpoints

  vpc_id              = var.vpc_id
  service_name        = each.value.service_name
  vpc_endpoint_type   = lookup(each.value, "vpc_endpoint_type", "Gateway")
  subnet_ids          = lookup(each.value, "vpc_endpoint_type", "Gateway") == "Interface" ? each.value.subnet_ids : null
  security_group_ids  = lookup(each.value, "vpc_endpoint_type", "Gateway") == "Interface" ? each.value.security_group_ids : null
  route_table_ids     = lookup(each.value, "vpc_endpoint_type", "Gateway") == "Gateway" ? each.value.route_table_ids : null
  private_dns_enabled = lookup(each.value, "private_dns_enabled", true)
  policy              = lookup(each.value, "policy", null)

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-vpc-endpoint-${each.key}"
    }
  )
}

