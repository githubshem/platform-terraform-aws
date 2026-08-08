

output "public_alb_url" {
  description = "The DNS name of the load balancer"
  # Reference the resource directly, not a module
  value = aws_lb.public.dns_name
}

output "public_alb_sg_id" {
  description = "The ID of the security group attached to the ALB"
  # Reference the resource directly, not a module
  value = var.create_sg ? aws_security_group.public_alb_sg[0].id : var.existing_sg_id
}

output "fe_target_groups" {
  description = "A map of all target group ARNs"
  # Reference the resource directly, not a module
  value = { for k, v in aws_lb_target_group.fe_targets : k => v.arn }
}