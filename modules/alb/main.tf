resource "aws_lb" "main" {
  name               = "${var.name_prefix}-alb"
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids

  enable_deletion_protection = var.enable_deletion_protection
  enable_http2               = var.enable_http2
  enable_tls_version_and_cipher_suite_headers = var.enable_tls_version_and_cipher_suite_headers
  enable_xff_client_port     = var.enable_xff_client_port
  idle_timeout                = var.idle_timeout
  ip_address_type             = var.ip_address_type
  drop_invalid_header_fields  = var.drop_invalid_header_fields

  access_logs {
    enabled = var.enable_access_logs
    bucket  = var.access_logs_bucket
    prefix  = var.access_logs_prefix
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-alb"
    }
  )
}

resource "aws_lb_target_group" "main" {
  for_each = var.target_groups

  name                 = "${var.name_prefix}-tg-${each.key}"
  port                 = each.value.port
  protocol             = each.value.protocol
  vpc_id               = var.vpc_id
  target_type          = each.value.target_type
  deregistration_delay = lookup(each.value, "deregistration_delay", 300)

  health_check {
    enabled             = lookup(each.value.health_check, "enabled", true)
    healthy_threshold   = lookup(each.value.health_check, "healthy_threshold", 2)
    unhealthy_threshold = lookup(each.value.health_check, "unhealthy_threshold", 2)
    timeout             = lookup(each.value.health_check, "timeout", 5)
    interval            = lookup(each.value.health_check, "interval", 30)
    path                = lookup(each.value.health_check, "path", "/")
    protocol            = lookup(each.value.health_check, "protocol", "HTTP")
    matcher             = lookup(each.value.health_check, "matcher", "200")
  }

  stickiness {
    enabled         = lookup(each.value, "stickiness_enabled", false)
    type            = lookup(each.value, "stickiness_type", "lb_cookie")
    cookie_duration = lookup(each.value, "stickiness_cookie_duration", 86400)
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-tg-${each.key}"
    }
  )
}

resource "aws_lb_listener" "main" {
  for_each = var.listeners

  load_balancer_arn = aws_lb.main.arn
  port              = each.value.port
  protocol          = each.value.protocol
  ssl_policy        = lookup(each.value, "ssl_policy", null)
  certificate_arn   = lookup(each.value, "certificate_arn", null)

  default_action {
    type             = lookup(each.value.default_action, "type", "forward")
    target_group_arn = lookup(each.value.default_action, "target_group_arn", null) != null ? aws_lb_target_group.main[each.value.default_action.target_group_arn].arn : null
  }
}

