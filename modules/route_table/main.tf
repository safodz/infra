resource "aws_route_table" "public" {
  count = var.create_public ? 1 : 0

  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.internet_gateway_id
  }

  dynamic "route" {
    for_each = var.additional_routes
    content {
      cidr_block                = route.value.cidr_block
      gateway_id                = lookup(route.value, "gateway_id", null)
      nat_gateway_id            = lookup(route.value, "nat_gateway_id", null)
      vpc_peering_connection_id = lookup(route.value, "vpc_peering_connection_id", null)
      transit_gateway_id        = lookup(route.value, "transit_gateway_id", null)
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-public-rt"
      Type = "public"
    }
  )
}

resource "aws_route_table" "private" {
  count = var.create_private ? length(var.private_subnet_ids) : 0

  vpc_id = var.vpc_id

  dynamic "route" {
    for_each = var.nat_gateway_ids != null && length(var.nat_gateway_ids) > count.index ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = var.nat_gateway_ids[count.index]
    }
  }

  dynamic "route" {
    for_each = var.additional_routes
    content {
      cidr_block                = route.value.cidr_block
      gateway_id                = lookup(route.value, "gateway_id", null)
      nat_gateway_id            = lookup(route.value, "nat_gateway_id", null)
      vpc_peering_connection_id = lookup(route.value, "vpc_peering_connection_id", null)
      transit_gateway_id        = lookup(route.value, "transit_gateway_id", null)
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-private-rt-${count.index + 1}"
      Type = "private"
    }
  )
}

resource "aws_route_table_association" "public" {
  count = var.create_public ? length(var.public_subnet_ids) : 0

  subnet_id      = var.public_subnet_ids[count.index]
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table_association" "private" {
  count = var.create_private ? length(var.private_subnet_ids) : 0

  subnet_id      = var.private_subnet_ids[count.index]
  route_table_id = aws_route_table.private[count.index].id
}

