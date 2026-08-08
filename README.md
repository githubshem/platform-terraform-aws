# plat-terraform

Infrastructure-as-Code for the ExampleCorp engineering platform. This repository
holds every Terraform stack (ECS, RDS, Redis, RabbitMQ, ALB, networking,
observability) plus the Jenkins pipeline definitions that plan and apply them.

This README is the authoritative, repo-wide reference for **structure**,
**naming**, **environments**, and **automation scope**. Read it before adding a
new stack or changing an existing one.

---

## 1. Repository layout

```
plat-terraform/
├── README.md                      ← this file (repo-wide conventions)
├── .tflint.hcl                    ← TFLint config used by Jenkins quality gates
├── .trivyignore                   ← accepted Trivy findings (with justification)
├── Scripts/
│   └── generate-lockfiles.sh      ← regenerate .terraform.lock.hcl for all workspaces
├── jenkins/                       ← Jenkins pipeline definitions (see jenkins/README.md)
│   ├── shared/terraform_common.groovy
│   ├── Jenkinsfile.ecs | .eks | .rds | .redis | .rabbitmq | .alb | .vpc
│   ├── Jenkinsfile.drift-detection | .terraform-state-backup | .rabbitmq-backup
│   └── README.md
└── Terraform/
    ├── modules/                   ← modules shared by more than one stack
    ├── 00-network/                ← vpc, security-groups
    ├── 10-data/                   ← aurora-mysql, elasticache, rabbitmq(+backup), opensearch, mq
    ├── 20-platform/               ← alb/ (internal, public, ui, dns-sync), eks/
    ├── 30-workloads/              ← zeus/hera services and frontends
    └── 90-ops/                    ← jenkins, state-backup
```

**Layers are numbered in dependency order.** `00-network` publishes the VPC and
security-group outputs that `10-data` and above consume; `20-platform` fronts the
workloads in `30-workloads`. Reading top to bottom is reading apply order, and a
stack should only ever depend on a lower number than itself.

Layer contents:

| Layer | Holds | Depends on |
| ----- | ----- | ---------- |
| `00-network` | VPC, subnets, NAT, security groups | nothing |
| `10-data` | Aurora, ElastiCache, RabbitMQ, OpenSearch | `00-network` |
| `20-platform` | Load balancers, EKS control planes and node groups | `00-network` |
| `30-workloads` | ECS services and frontends | `00-network`, `20-platform` |
| `90-ops` | Jenkins, state backup | `00-network` |

> `INFRA/` is gone. It was a junk drawer holding Jenkins, OpenSearch, MQ and the
> state-backup stack, which share nothing; each now sits in the layer it belongs to.

### Canonical stack layout

Every deployable stack MUST follow this shape:

```
Terraform/<NN-layer>/<stack>/
├── modules/          # only if used by this stack alone
└── environments/<env>/[<group>/]<leaf>/
    ├── backend.tf
    ├── providers.tf
    ├── variables.tf
    ├── main.tf
    └── terraform.tfvars
```

Rules:

- Always `environments/` (never `env/`).
- The var-file is always `terraform.tfvars` (never `<env>.tfvars`).
- Leaf names are **environment-agnostic**: the same leaf name is reused across
  environments (e.g. `selene` under both `test/` and `prod/`). Never
  bake the environment into the leaf name.

---

## 2. Naming conventions

- Folders and stack names: lowercase `kebab-case`.
- No `terraform` / `tf` noise in names. The whole repo is Terraform, so the
  prefix/suffix carries no information (`security-groups`, not `securitygroups-tf`).
- Name by role, not by tool (`zeus-services`, `zeus-frontend`, `openapi-public`).
- Modules are referenced with relative `source` paths, so moving a stack never
  breaks module references as long as the stack moves as a unit.
- Modules used by more than one stack live in `Terraform/modules/`; modules used
  by a single stack stay inside it. That keeps the shared set small and obvious.

---

## 3. Environments

There are exactly two: `test` and `prod`. Every environment folder in the repo is one
of those two. The environments are symmetric — 50 workspaces in `test`, 51 in `prod` —
and the single difference is `90-ops/jenkins`, which is prod-only by decision (below).
102 workspaces in total.

| Environment | State bucket                | Notes                                    |
| ----------- | --------------------------- | ---------------------------------------- |
| `test`      | `plat-test-terraform-state` | Matches Jenkins `TERRAFORM_ENV=test`.    |
| `prod`      | `plat-prod-terraform-state` | Matches Jenkins `TERRAFORM_ENV=prod`.    |

Earlier names (`uat`, `uat-titan`, `upgrade`, `dev`, `release`) are gone, not merely
deprecated:

- `uat-titan → test`, `upgrade → prod`, and `uat` folded into `test`.
- `dev` (rabbitmq-backup) was removed. It differed from `uat` by broker type rather
  than by environment, so it was never really a separate environment.
- `release/rabbitmq` was removed. It was a placeholder scaffold full of `REPLACE`
  values, superseded by the real config now at `prod/rabbitmq`.

`90-ops/jenkins` has a `prod` workspace and no `test` counterpart. A second
Jenkins controller is an infrastructure decision, not a refactor, so it was not
invented here.

---

## 4. Automation scope (Jenkins pipelines)

Pipelines live in `jenkins/` and are consumed by Jenkins via "Pipeline script from
SCM". See [jenkins/README.md](jenkins/README.md) for setup and per-job details.

| Stack | Pipeline posture |
| ----- | ---------------- |
| `30-workloads/{zeus,hera}-services` | Quality gates + plan + policy check + gated apply |
| `10-data/{aurora-mysql,elasticache,rabbitmq}` | Quality gates + plan + policy check + gated apply |
| `20-platform/alb/*`, `20-platform/eks/*`, `00-network/*` | Quality gates + plan + policy check + gated apply (restricted approvers) |
| Drift detection | Scheduled plan-only, 98 workspaces (`jenkins/Jenkinsfile.drift-detection`) |
| State backup | Scheduled read-only sync of both state buckets |
| RabbitMQ definitions backup | Scheduled shell backup |
| `30-workloads/{zeus,hera}-frontend` | Excluded (no Jenkins pipeline; manage out-of-band) |
| `90-ops/jenkins` | Excluded (self-management hazard) |
| `90-ops/state-backup` | Excluded (one-time / out-of-band apply for the backup bucket) |
| `10-data/opensearch` | Domain is in drift scope; `ism/` excluded (needs in-VPC access) |
| `10-data/mq` | Excluded (placeholder values, no backend, not deployable) |
| `10-data/rabbitmq-backup` | Excluded from deploy pipelines (shell backup job only) |
| `20-platform/alb/dns-sync` | Excluded (no Terraform `.tf` files; see its README) |

**ECS pipeline:** use `jenkins/Jenkinsfile.ecs` only. It covers `*-services`, not
the frontends. The legacy in-tree pipeline and its tombstone README were removed
with the restructure, since the path they pointed from no longer exists.

**CI quality gates** (all deploy pipelines, before plan):

- `terraform fmt -check`, backend key validation, provider lock check, no provider profile
- Post-init: `terraform validate`, tflint, Trivy (HIGH/CRITICAL fail)
- Pre-apply state snapshot to the backup bucket

Repo-root [`.tflint.hcl`](.tflint.hcl) and [`.trivyignore`](.trivyignore) are used by
those gates. See [jenkins/README.md](jenkins/README.md) Section 9 for tool versions
and operator notes.

**Repo maintenance:** after adding or changing providers, regenerate lock files from
the repo root:

```bash
./Scripts/generate-lockfiles.sh
```

Commit the resulting `.terraform.lock.hcl` files. Quality gates fail if a workspace
is missing its lock file.

Why the exclusions:

- **`90-ops/jenkins`** manages the Jenkins server itself. Applying it
  through that same Jenkins can kill the running build mid-apply. Manage it out-of-band.
- **`10-data/mq`** still contains placeholder values and no backend; it is not
  deployable as-is.
- **Frontends** have Terraform workspaces but no dedicated Jenkinsfile; deploy
  them out-of-band until a pipeline is added.
- **`90-ops/state-backup`** creates the destination bucket used by the
  scheduled state-backup job; apply it once out-of-band, not via self-service pipelines.
- **`10-data/rabbitmq-backup`** Terraform stacks are separate from the daily
  definitions backup job (`Jenkinsfile.rabbitmq-backup`).

---

## 5. Terraform state

- **State is isolated per environment.** `test` state lives in
  `plat-test-terraform-state`, `prod` in `plat-prod-terraform-state`, both in
  `ap-southeast-1` with lock table `terraform-state-locking`. A prod apply cannot
  reach test state, and the two buckets can carry different policies and IAM.
- Keys follow `<env>/<category>/<leaf>/terraform.tfstate` and every key is unique.
- The Jenkins gate accepts either bucket and additionally cross-checks them: a `prod/`
  key in the test bucket (or the reverse) fails before `init`, so passing the bucket
  check is not enough on its own.
- One deliberate exception: `90-ops/state-backup` uses the key
  `terraform-state-backup/terraform.tfstate` with no environment prefix, because it is
  a cross-environment utility. Keys without an `<env>/` prefix are not subject to the
  cross-check above.
- Pipelines are plan-first with a human approval gate before any apply. `destroy`
  is gated / not exposed via self-service pipelines.

### Cross-stack data flow

Network identifiers are **never** hardcoded. Downstream stacks read them from the VPC
and security-group stacks through `terraform_remote_state`, so replacing a subnet or a
security group propagates on the next apply instead of silently drifting:

| Need                     | Source                                              |
| ------------------------ | --------------------------------------------------- |
| VPC id                   | `vpc.outputs.vpc_id`                                |
| ECS / app tier subnets   | `vpc.outputs.private_app_subnet_ids`                |
| Data tier subnets        | `vpc.outputs.data_subnet_ids` (RDS, Redis, OpenSearch, RabbitMQ) |
| Public subnets           | `vpc.outputs.public_subnet_ids` (public ALB, Jenkins) |
| Backend / data SG        | `security_groups.outputs.ecs_be_sg_id`              |
| Public ALB SG            | `security_groups.outputs.alb_public_sg_id`          |

Subnet output lists are sorted by AZ. That matters for consumers that index into them
(`public_subnet_ids[0]`): an unordered `aws_subnets` data-source lookup can return a
different subnet between applies and silently move an instance to another AZ.

The VPC stack's outputs are a published interface — renaming one is a breaking change
for every stack listed above.

### Two-stage stacks

`10-data/opensearch` applies in two steps, and the order is not optional:

1. `environments/<env>/` creates the domain.
2. `environments/<env>/ism/` applies the retention policy, index template and
   bootstrap index.

They are separate workspaces because the `opensearch` provider must be
configured with the domain's endpoint, and a provider block cannot depend on a
resource created in the same apply. The split also confines the network
requirement: the domain has no public endpoint, so `ism/` only works from inside
the VPC — a Jenkins agent in a private subnet. It will hang and time out from a
laptop. The domain stack itself has no such constraint.

The three ISM resources only work together: the policy describes rollover and
retention, the composable index template stamps the rollover alias onto matching
indices, and the bootstrap index carries the write alias so the first rollover
has something to roll over from. Omit the bootstrap index and the policy attaches
but never fires.

### EKS and ECS

Every ECS workload has an EKS home. The mapping is deliberately **not** one EKS
cluster per ECS cluster:

| ECS today | EKS |
| --------- | --- |
| 27 clusters per environment (20 zeus, 7 hera) | 4 clusters total: `{zeus,hera}` x `{test,prod}` |
| each cluster = one leaf workspace | each ECS cluster becomes a namespace |
| 127 microservices | Deployments in those namespaces |

One control plane per ECS cluster would be 54 of them, about $47k a year before
a single node runs. Namespaces give the same isolation boundary for scheduling
and RBAC at no control-plane cost.

Node pools mirror the ECS instance types (`r7i.large` for apps), so moving a
service between ECS and EKS does not silently change the hardware under it. The
`system` pool is tainted `CriticalAddonsOnly` so CoreDNS and controllers keep
capacity when the app pool is saturated.

The API endpoint is **private**. This stack only calls the AWS API, so its
pipeline runs anywhere; anything using the `kubernetes` or `helm` provider must
run from inside the VPC.

### IAM model

All deployable stacks target a single AWS account. There is no cross-account
`assume_role` provider pattern in this repo. Jenkins authenticates via the
`AWS_SESSION_TOKEN` credential (environment-based). ECS and similar stacks reference
pre-existing IAM role ARNs from `terraform.tfvars` rather than creating those roles
in Terraform.

---

## 6. Outstanding work

Cleared since the rebuild: state-key normalization, the environment rename, the
Redis state-key bug, stray `*.new` files, env-embedded Redis leaf names, dead
`aws_profile` plumbing, the `target_capacity` string/number split, ECS module
duplication, the Jenkins SSH exposure, and the Aurora / Redis / OpenSearch
resilience gaps. What remains:

1. **Redis encryption is staged but not applied.** `at_rest_encryption_enabled`
   and `transit_encryption_enabled` are now `true` in all eight workspaces, and
   both are **immutable on a live replication group** — applying replaces the
   cluster. Transit encryption also makes the endpoint TLS-only, so every client
   must speak TLS *before* the apply or it will connect to a healthy cluster and
   fail. Sequence: test first, confirm clients, then prod, and not bundled with
   any other change. Prod now takes a final snapshot (it previously did not).

2. **Three prod Redis clusters use `test-`prefixed parameter groups**
   (`gaia` and `persephone` → `test-eks-pg`, `selene` → `test-eks-pg-01`). The
   names look wrong for prod, but they refer to real parameter groups in the
   account, and repointing prod at a group that does not exist would fail the
   apply. Someone needs to confirm what those groups contain before this moves.

3. **`10-data/mq`** is a single `main.tf` of placeholder values with no backend.
   It is the only place hardcoded `vpc-`/`subnet-`/`sg-` literals remain, and it
   is excluded from every pipeline.

4. **No `test` Jenkins controller.** `90-ops/jenkins` is prod-only, and is the
   only difference between the two environments. Standing up a second controller
   is an infrastructure decision rather than a refactor.

5. **EKS has clusters but no workloads yet.** `20-platform/eks` builds the four
   control planes and node groups. The namespace-and-Deployment layer that gives
   each ECS service its EKS counterpart needs the `kubernetes` provider and must
   run from inside the VPC, the same constraint as `opensearch/ism`.

> **Not a gap:** the Jenkins instance role
> (`90-ops/jenkins/modules/jenkins/iam.tf`) deliberately grants no
> Terraform-apply permissions. The pipelines authenticate with the
> `AWS_SESSION_TOKEN` Jenkins credential, not the instance role, so those rights
> belong with that credential. Putting them on the instance role would hand full
> infrastructure access to every job on the box, and to anyone able to define one,
> without going through the credential at all. The role covers exactly what runs as
> the host: Session Manager, EFS mount, and the two scheduled backup jobs.

---

## 7. Cross-repo coupling

The companion repo `app-cicd` (`env-config.json`, per-service `task-def.json`)
references ECS cluster/service names by exact string. Renaming **stack folders**
is safe; renaming **leaf/service names** can desync deployments, so those names
need to be checked against `app-cicd` before they change.

---
