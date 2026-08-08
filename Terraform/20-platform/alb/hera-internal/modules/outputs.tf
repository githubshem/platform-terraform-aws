output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

output "target_group_arns" {
  value = { for k, v in aws_lb_target_group.this : k => v.arn }
}