output "alb_arn" {
  value = aws_lb.internal_alb.arn
}

output "alb_dns_name" {
  value = aws_lb.internal_alb.dns_name
}

output "alb_security_group_id" {
  value = aws_security_group.internal_alb_sg.id
}

output "target_group_arns" {
  value = { for name, tg in aws_lb_target_group.service_tg : name => tg.arn }
}

output "public_target_group_arns" {
  value = { for name, tg in aws_lb_target_group.public_service_tg : name => tg.arn }
}

output "public_rule_hosts" {
  value = {
    for name, svc in var.alb_services :
    name => "${name}-${var.environment}.${var.public_domain}"
    if var.create_public_alb_rules
  }
}
