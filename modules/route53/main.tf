resource "aws_route53_zone" "main" {
  count = var.create_zone ? 1 : 0

  name = var.zone_name

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-zone"
    }
  )
}

resource "aws_route53_record" "main" {
  for_each = var.records

  zone_id = var.zone_id != null ? var.zone_id : aws_route53_zone.main[0].zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = lookup(each.value, "ttl", 300)
  records = lookup(each.value, "records", [])

  dynamic "alias" {
    for_each = lookup(each.value, "alias", null) != null ? [each.value.alias] : []
    content {
      name                   = alias.value.name
      zone_id                = alias.value.zone_id
      evaluate_target_health = lookup(alias.value, "evaluate_target_health", false)
    }
  }
}

