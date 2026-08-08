output "domain_id" { value = aws_opensearch_domain.this.domain_id }
output "domain_endpoint" { value = aws_opensearch_domain.this.endpoint }
output "security_group_id" { value = aws_security_group.opensearch_sg.id }