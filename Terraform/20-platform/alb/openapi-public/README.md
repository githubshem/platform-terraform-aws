# OpenAPI ALB

This stack creates an internal ALB dedicated to OpenAPI back-end services.
It can also attach host-based rules on an existing public ALB HTTPS listener.

## Name behavior
- ALB name is exact from `alb_name` (no automatic `-environment` suffix).
- Keep ALB names <= 32 characters due to AWS limits.

## Public ALB host rules
- Enable with `create_public_alb_rules = true`.
- Provide `public_alb_https_listener_arn` for your existing public ALB listener.
- Public target group names follow: `${public_tg_name_prefix}-${service}-tg`.
	For prod, set `public_tg_name_prefix = "plat-prod"`, which yields names like `plat-prod-openapi-hermes-tg`.
- Host-based rules are generated as:
	`openapi-servicename-prod.example.com`
	Example: `openapi-hermes-prod.example.com`.

## Deploy
```bash
cd environments/test   # or environments/prod
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

## Import existing ALB (optional)
If ALB and related resources already exist, import before apply.
At minimum:
- ALB
- Security group
- Target groups
- Listeners

Use `terraform plan` first to identify exact import addresses.
