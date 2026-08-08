output "target_group_arns" {
  description = "Map of service names to their Target Group ARNs"
  value       = { for k, tg in aws_lb_target_group.service_tg : k => tg.arn }
}

output "alb_dns_name" {
  value = aws_lb.internal_alb.dns_name
}