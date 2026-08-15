# Security Policy

This repository is a portfolio and reference implementation. It must contain
only fictionalized infrastructure examples and must never be treated as an
inventory of a real organization or as deployable production configuration.

## Supported Versions

Security fixes are applied only to the latest commit on `main`. Historical
commits, forks, and deployments created from this repository are not supported.

## Reporting a Vulnerability

Do not disclose a vulnerability, credential, personal information, or details
about a potentially affected system in a public issue or pull request.

Use GitHub's **Security > Report a vulnerability** form for this repository. If
private vulnerability reporting is unavailable, contact the repository owner
through a private channel listed on their GitHub profile and include only enough
information to arrange a secure handoff.

Please include:

- the affected file, module, or revision;
- the security impact and realistic attack scenario;
- minimal reproduction or proof-of-concept steps; and
- any recommended remediation, if known.

Reports are handled on a best-effort basis. The maintainer will try to
acknowledge a report within 7 days and provide a remediation decision within 30
days. These are targets, not a service-level agreement.

## Publication and Contribution Guardrails

Every contributor is responsible for confirming that they have the right to
publish their contribution. Do not submit source code, configuration, names,
documentation, or operational knowledge owned by a current or former employer,
client, or other third party.

Public examples must use unmistakably synthetic values such as `example.com`,
`ExampleCorp`, `123456789012`, and patterned resource identifiers. Before a
commit or release, remove or replace all real:

- organization, product, repository, domain, and email names;
- cloud account IDs, ARNs, resource IDs, bucket names, hosted-zone IDs, and
  certificate IDs;
- IP ranges, subnet plans, internal DNS names, ports, and network topology;
- secret paths, key aliases, IAM role names, Jenkins credential IDs, approver
  names, ticket IDs, and cost-center tags;
- image registry paths, build tags, workload inventories, and service names; and
- comments or commit metadata that identify people or internal processes.

Avoid publishing an exact one-for-one replica of a private system even after
renaming it. Aggregate, simplify, or redesign the example so its topology and
workload inventory cannot be used as an organizational fingerprint.

## Secrets and Terraform State

- Never commit credentials, tokens, private keys, certificates, `.env` files,
  Terraform state, saved plans, crash logs, CLI credentials, or generated
  override files.
- A Terraform variable marked `sensitive` can still be stored in state. Retrieve
  secrets at runtime from an approved secret manager and protect the state
  backend with encryption, access logging, versioning, and least privilege.
- Keep environment-specific values outside the public repository. New examples
  should use clearly named sample files such as `terraform.tfvars.example`.
- Do not place secrets in Git history and then rely on a later deletion. Git
  retains earlier versions until history is deliberately rewritten.
- Treat CI logs, plan output, build artifacts, and screenshots as potential
  disclosure paths.

## Required Checks Before Publication

Run equivalent checks locally or in CI before publishing:

```bash
terraform fmt -check -recursive
tflint --recursive
trivy config --severity HIGH,CRITICAL --exit-code 1 .
gitleaks git --redact
```

In addition:

1. Run `terraform init -backend=false` and `terraform validate` in each changed
   root module.
2. Review the complete reachable Git history, not only the current working tree,
   for secrets and identifying terms.
3. Inspect every staged file and confirm that generated files and local tooling
   metadata are excluded.
4. Review every security-scanner suppression. A suppression must be narrowly
   scoped, justified, owned, and time-bounded; blanket or undocumented
   suppressions are not accepted.
5. Confirm that examples use least privilege, encryption, current TLS policies,
   IMDSv2, restricted ingress and egress, and private control-plane endpoints
   where applicable. Document any intentional exception next to the code.

These checks reduce risk but do not prove that a repository is safe or legally
authorized for public release. A manual provenance review is always required.

## If Sensitive Data Is Committed

1. Revoke or rotate the exposed credential immediately. Deleting the file is not
   sufficient.
2. Determine the affected accounts, resources, logs, artifacts, forks, and
   commit range.
3. Remove the data from every reachable revision with a history-rewriting tool,
   then force-push only after coordinating with collaborators.
4. Invalidate caches and artifacts, notify affected owners, and review audit logs
   for misuse.
5. Document the cause and add a test or guardrail that prevents recurrence.

Assume a published secret is compromised even if the repository was public only
briefly.
