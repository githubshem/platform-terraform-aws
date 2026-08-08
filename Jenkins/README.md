# Jenkins Terraform Pipelines: Setup & Usage Guide

> **Repo-wide conventions:** For repository structure, naming, the environment
> model (active vs deprecated), automation scope, and the deferred state-migration
> backlog, see the authoritative repo-root [`../README.md`](../README.md).

> **Where files live:** All Jenkinsfiles and the shared helper are stored **inside this GitLab
> repository** (`plat-terraform`) under the `Jenkins/` folder.
> Jenkins reads them directly from GitLab; you never paste pipeline code into the Jenkins UI.

---

## 1. Repository layout (what is stored in GitLab)

```
plat-terraform/
└── Jenkins/
    ├── shared/
    │   └── terraform_common.groovy   ← Reusable helper loaded by every pipeline
    ├── Jenkinsfile.ecs               ← Pipeline for ECS service deployments
    ├── Jenkinsfile.rds               ← Pipeline for RDS cluster changes
    ├── Jenkinsfile.redis             ← Pipeline for Redis (ElastiCache) changes
    ├── Jenkinsfile.rabbitmq          ← Pipeline for RabbitMQ changes
    ├── Jenkinsfile.alb               ← ALB (quality gates + policy-checked gated apply)
    ├── Jenkinsfile.vpc               ← VPC + security groups (quality gates + gated apply)
    ├── Jenkinsfile.drift-detection   ← Scheduled drift detection (plan-only)
    ├── Jenkinsfile.terraform-state-backup  ← Daily read-only S3 state sync
    ├── Jenkinsfile.rabbitmq-backup   ← Daily RabbitMQ definitions backup to S3
    └── README.md                     ← This file
```

**ECS canonical path:** `Jenkins/Jenkinsfile.ecs`. Do **not** use the retired
in-tree `Terraform/ECS/pipelines/` path, which was removed with the restructure.

**Rule:** Every change to pipeline logic is a GitLab merge request (full history, reviews,
rollback). No one edits pipelines directly in Jenkins.

---

## 2. How each Jenkinsfile works

All deploy pipelines follow this stage order:

```
Checkout Code
    │
Resolve Terraform Path
    │
Quality Gates (pre-init)   ← fmt, backend key, no-profile, lock file, required files
    │
Terraform Init             ← -lockfile=readonly
    │
Quality Gates (post-init)  ← validate, tflint, Trivy
    │
Terraform Plan             ← archives tfplan + plan_summary.txt
    │
Policy Check               ← flags destroy/replace in plan
    │
Approval Gate  ┐           ← only when RUN_APPLY = true
State Snapshot ┤           ← pre-apply state copy to backup bucket
Terraform Apply┘
```

ALB and VPC use the same flow but require **named approvers** (set `APPROVERS` at the
top of `Jenkinsfile.alb` / `Jenkinsfile.vpc`).

The drift-detection job runs plan-only across a fixed stack matrix on a daily cron.
The state-backup and rabbitmq-backup jobs are scheduled shell/AWS sync pipelines
(not Terraform apply). See Sections 5.7-5.9.

The shared helper `Jenkins/shared/terraform_common.groovy` provides `runQualityGatesPreInit`,
`runQualityGatesPostInit`, `tfInit`, `tfPlan`, `policyCheck`, `snapshotStateBeforeApply`,
`tfApply`, `approvalGate`, and `archivePlanArtifacts`.

---

## 3. Jenkins server: one-time setup (admin does this once)

### 3.1 Required plugins

Install these from **Manage Jenkins → Plugins → Available**:

| Plugin | Why needed |
|---|---|
| **Pipeline** (`workflow-aggregator`) | Declarative pipeline support |
| **Git** (`git`) | Checkout from GitLab |
| **Credentials Binding** (`credentials-binding`) | `withCredentials` block |
| **Amazon Web Services SDK** (`aws-java-sdk`) | AWS credential type |
| **Active Choices** (`uno-choice`) | Reactive dropdowns (APP_NAME → SERVICE_NAME, ENV → CLUSTER) |
| **Terraform** (`terraform`) | `tools { terraform }` block |

### 3.2 Terraform tool

**Manage Jenkins → Global Tool Configuration → Terraform → Add Terraform**

| Field | Value |
|---|---|
| Name | `terraform-1.15.5` ← must match exactly what is in every Jenkinsfile |
| Install automatically | ✅ tick, choose version `1.15.5` from HashiCorp |

> If Terraform is already installed on the Jenkins agent, set the install directory path
> instead of auto-install.

### 3.3 Credentials

**Manage Jenkins → Credentials → System → Global credentials → Add Credentials**

#### GitLab credential

| Field | Value |
|---|---|
| Kind | **Username with password** |
| Username | GitLab service account username |
| Password | GitLab personal access token (scope: `read_repository`) |
| ID | `git-grafana` ← must match exactly |
| Description | GitLab plat-terraform read access |

#### AWS credential

| Field | Value |
|---|---|
| Kind | **AWS Credentials** |
| Access Key ID | AWS access key for the deployment role |
| Secret Access Key | AWS secret key |
| ID | `AWS_SESSION_TOKEN` ← must match exactly |
| Description | AWS IAM role for Terraform deployments |

> If you use STS assume-role tokens that rotate, store the role ARN and use the
> **AWS Assume Role** plugin to auto-refresh. The credential ID stays `AWS_SESSION_TOKEN`.

#### RabbitMQ backup credential (for `terraform-rabbitmq-backup` only)

| Field | Value |
|---|---|
| Kind | **Username with password** |
| Username | RabbitMQ management admin user |
| Password | RabbitMQ management password |
| ID | `rmq-zeus-admin` ← must match exactly |
| Description | RabbitMQ management API for definitions backup |

The state-backup and rabbitmq-backup jobs also rely on the Jenkins host IAM role
(e.g. `zeus-jenkins-role`) for S3 access. See Sections 5.8-5.9.

---

## 4. Jenkins server: create one Pipeline job per resource type

Repeat these steps for each job: ECS, RDS, Redis, RabbitMQ, ALB, VPC, and optionally
drift-detection, terraform-state-backup, and terraform-rabbitmq-backup.

### Step-by-step: New Pipeline job

1. **Dashboard → New Item**
2. Enter a name: e.g., `terraform-rds`, `terraform-ecs`, `terraform-redis`, `terraform-rabbitmq`
3. Select **Pipeline** → click **OK**

#### General tab
- ✅ **This project is parameterised**: add parameters as described in Section 5 below
- ✅ **Do not allow concurrent builds** (prevents two applies running simultaneously)

#### Build Triggers tab
- Leave blank for deploy jobs. Those pipelines are **always triggered manually** via "Build with Parameters".
- Scheduled jobs (drift, state backup, rabbitmq backup) define cron **in the Jenkinsfile**; no UI trigger is required.

#### Pipeline tab

| Field | Value |
|---|---|
| Definition | **Pipeline script from SCM** |
| SCM | **Git** |
| Repository URL | `https://git.example.com/example-org/platform-terraform-aws.git` |
| Credentials | `git-grafana` |
| Branch Specifier | `*/main` (or your default branch) |
| Script Path | `Jenkins/Jenkinsfile.rds` ← change per job |
| Lightweight checkout | ✅ tick |

Click **Save**.

---

## 5. Parameters to add in Jenkins UI (per job)

> **Why here and not in the Jenkinsfile?**
> For most jobs, `choice()` and `booleanParam()` can be defined inside the Jenkinsfile;
> Jenkins picks them up automatically on the first run.
> **The ECS job is different:** any `parameters {}` block in `Jenkins/Jenkinsfile.ecs`
> causes Jenkins to re-sync parameters on every run, which overwrites Active Choices UI
> settings (`APP_NAME`, `SERVICE_NAME`) back to plain String parameters.
> **All `terraform-ecs` parameters must therefore be configured in the Jenkins UI only.**

### 5.1 ECS job (`terraform-ecs`)

Configure **all six** parameters in the Jenkins UI under **Configure → This project is parameterised**:

#### Parameter 1: GIT_REPO_URL

| Field | Value |
|---|---|
| Type | **String Parameter** |
| Name | `GIT_REPO_URL` |
| Default Value | `https://git.example.com/example-org/platform-terraform-aws.git` |
| Description | plat-terraform repository URL |

#### Parameter 2: GIT_BRANCH

| Field | Value |
|---|---|
| Type | **String Parameter** |
| Name | `GIT_BRANCH` |
| Default Value | `main` |
| Description | Branch to check out |

#### Parameter 3: TERRAFORM_ENV

| Field | Value |
|---|---|
| Type | **Choice Parameter** |
| Name | `TERRAFORM_ENV` |
| Choices | `test`, `prod` |
| Description | Target environment |

#### Parameter 4: RUN_APPLY

| Field | Value |
|---|---|
| Type | **Boolean Parameter** |
| Name | `RUN_APPLY` |
| Default Value | *(unticked)* |
| Description | Tick to enable Approval Gate + Apply (leave unticked for plan-only runs) |

#### Parameter 5: APP_NAME

| Field | Value |
|---|---|
| Type | **Active Choices Parameter** |
| Name | `APP_NAME` |
| Script (Groovy) | `return ['zeus', 'hera']` |
| Choice Type | **Single Select** |
| Description | Application cluster |

#### Parameter 6: SERVICE_NAME

| Field | Value |
|---|---|
| Type | **Active Choices Reactive Parameter** |
| Name | `SERVICE_NAME` |
| Referenced parameters | `APP_NAME` |
| Script (Groovy) | *(paste below)* |
| Choice Type | **Single Select** |
| Description | Service to deploy |

```groovy
if (APP_NAME == 'zeus') {
    return ['hermes','apollo','ares','zeus','artemis','hestia','demeter','hades',
            'hephaestus','hecate','helios','iris','triton','nereus',
            'proteus','arachne','kronos','rhea','morpheus','orion']
} else if (APP_NAME == 'hera') {
    return ['metis','themis','plutus','atlas','moirai','mnemosyne','notus']
} else {
    return ['-- select APP_NAME first --']
}
```

> This job covers `{app}-services` only. `zeus-frontend` and `hera-frontend` are
> not in the pipeline path; manage them out-of-band (see root README Section 4).

---

### 5.2 RDS job (`terraform-rds`)

The Jenkinsfile already defines: `GIT_REPO_URL`, `GIT_BRANCH`, `TERRAFORM_ENV` (choice),
`RUN_APPLY` (boolean).

Add this one in the Jenkins UI:

#### Parameter: CLUSTER_NAME

| Field | Value |
|---|---|
| Type | **Active Choices Reactive Parameter** |
| Name | `CLUSTER_NAME` |
| Referenced parameters | `TERRAFORM_ENV` |
| Script (Groovy) | *(paste below)* |
| Choice Type | **Single Select** |
| Description | RDS cluster to target |

```groovy
// Cluster names are the same in both test and prod
return [
    'selene',
    'athena',
    'persephone',
    'gaia',
    'horae'
]
```

---

### 5.3 Redis job (`terraform-redis`)

The Jenkinsfile already defines: `GIT_REPO_URL`, `GIT_BRANCH`, `TERRAFORM_ENV` (choice),
`RUN_APPLY` (boolean).

Add this one in the Jenkins UI:

#### Parameter: CLUSTER_NAME

| Field | Value |
|---|---|
| Type | **Active Choices Reactive Parameter** |
| Name | `CLUSTER_NAME` |
| Referenced parameters | `TERRAFORM_ENV` |
| Script (Groovy) | *(paste below)* |
| Choice Type | **Single Select** |
| Description | Redis cluster to target |

```groovy
if (TERRAFORM_ENV == 'test') {
    return ['selene','hera','persephone','gaia']
} else if (TERRAFORM_ENV == 'prod') {
    return ['selene','hera','persephone',
            'gaia']
} else {
    return ['-- select TERRAFORM_ENV first --']
}
```

---

### 5.4 RabbitMQ job (`terraform-rabbitmq`)

No Active Choices parameters needed.
The Jenkinsfile already defines everything: `GIT_REPO_URL`, `GIT_BRANCH`,
`TERRAFORM_ENV` (choice: `test`, `prod`), `RUN_APPLY` (boolean).

**Nothing extra to add in Jenkins UI.**

---

### 5.5 ALB job (`terraform-alb`)

No Active Choices parameters needed. The Jenkinsfile defines everything:
`GIT_REPO_URL`, `GIT_BRANCH`, `ALB_STACK`, `TERRAFORM_ENV` (choice: `test`,
`prod`), `RUN_APPLY` (boolean, default false).

Before enabling apply, set `APPROVERS` at the top of
`Jenkins/Jenkinsfile.alb` to a comma-separated list of Jenkins user IDs.

**Nothing extra to add in Jenkins UI.**

---

### 5.6 VPC job (`terraform-vpc`)

No Active Choices parameters needed. The Jenkinsfile defines everything:
`GIT_REPO_URL`, `GIT_BRANCH`, `VPC_STACK`, `TERRAFORM_ENV` (choice: `test`,
`prod`), `RUN_APPLY` (boolean, default false).

Before enabling apply, set `APPROVERS` at the top of
`Jenkins/Jenkinsfile.vpc` to a comma-separated list of Jenkins user IDs.

**Nothing extra to add in Jenkins UI.**

---

### 5.7 Drift detection job (`terraform-drift-detection`)

| Field | Value |
|---|---|
| Script Path | `Jenkins/Jenkinsfile.drift-detection` |
| Build Triggers | Cron is defined in-pipeline (`H 2 * * *` daily); no UI trigger needed |
| Parameters | `GIT_REPO_URL`, `GIT_BRANCH` (defined in Jenkinsfile) |

Build result semantics:

| Result | Meaning |
|---|---|
| SUCCESS | All stacks: NO DRIFT |
| UNSTABLE | One or more stacks: DRIFT DETECTED |
| FAILURE | One or more stacks: PLAN FAILED or PROVIDER/BACKEND ISSUE |

Review the `drift_report.txt` artifact after each run.

**Stack matrix (98 workspaces):** `30-workloads` (58), `10-data` (24),
`20-platform` (12), `00-network` (4).

The matrix is **discovered at runtime**, not hand-listed: `discoverStacks()` in
`Jenkins/Jenkinsfile.drift-detection` treats every directory containing a
`backend.tf` as in scope. The previous hardcoded list had fallen 58 workspaces
behind — every ECS service and frontend was silently unmonitored, which is where
config drifts most, since image tags and task definitions change on every deploy.
Adding a workspace now puts it under drift detection automatically.

**Not in the matrix:** `Terraform/90-ops/` via `excludedPrefixes`, plus the OpenSearch `ism/` workspaces via `excludedSuffixes`. Applying
those through the Jenkins they manage can kill the build mid-apply, and they are
deployed out-of-band.

Runs in 6 parallel lanes with workspaces dealt round-robin, so one slow category
does not land entirely in one lane. Bounded rather than fully parallel to avoid
~90 concurrent inits hammering the AWS API and the provider registry. Timeout is
180 minutes.

---

### 5.8 State backup job (`terraform-state-backup`)

| Field | Value |
|---|---|
| Script Path | `Jenkins/Jenkinsfile.terraform-state-backup` |
| Build Triggers | Cron in-pipeline: `0 3 * * *` (daily 03:00 UTC) |
| Parameters | None (no `parameters {}` block) |

What it does:

- Read-only `aws s3 sync` from **both** live state buckets
  (`plat-test-terraform-state`, `plat-prod-terraform-state`) to
  `plat-terraform-state-backup` under `terraform-state/<source-bucket>/`.
  Backing up only one would leave the other environment with no copy at all.
- Never writes to the source bucket, never touches DynamoDB locks, never runs with `--delete`

Prerequisites:

1. Destination bucket must exist (apply `Terraform/90-ops/state-backup` once, out-of-band).
2. Jenkins host IAM role needs `s3:GetObject` / `s3:ListBucket` on the source bucket and
   `s3:PutObject` / `s3:ListBucket` on the destination bucket.

This job can also be run manually from the Jenkins UI (Build Now).

---

### 5.9 RabbitMQ definitions backup job (`terraform-rabbitmq-backup`)

| Field | Value |
|---|---|
| Script Path | `Jenkins/Jenkinsfile.rabbitmq-backup` |
| Build Triggers | Cron in-pipeline: `0 2 * * *` (daily 02:00 UTC) |
| Parameters | None (reachability for hera is probed at runtime) |

What it does:

- Backs up RabbitMQ definitions (queues, exchanges, bindings, vhosts) to S3
- zeus (self-hosted ECS): management API via configured ALB host/port
- hera (Amazon MQ): TCP probe to management port; stage skips if unreachable

| Setting | Value |
|---|---|
| S3 bucket | `plat-prod-rabbitmq-definitions-backup` |
| Credential | `rmq-zeus-admin` (username/password) |
| Region | `ap-southeast-1` |

**Restore (manual).** A backup nobody can restore is not a backup, and this is the
only recovery path — download a snapshot and POST it back to the broker:

```bash
aws s3 cp s3://plat-prod-rabbitmq-definitions-backup/rabbitmq-definitions/<broker>/latest/definitions.json ./def.json
```

```bash
curl -u "$RMQ_USER:$RMQ_PASS" -H "content-type: application/json" -X POST "https://<broker-console-host>/api/definitions" -d @def.json
```

Run it from inside the VPC: the Amazon MQ console endpoints are not public. This
procedure previously lived in `Terraform/10-data/rabbitmq/scripts/README.md (removed)`,
which named a bucket (`plat-rabbitmq-backups`) that does not exist — the path
above is the one the job actually writes to.

Prerequisites:

1. Credential `rmq-zeus-admin` in Jenkins (Section 3.3).
2. S3 bucket `plat-prod-rabbitmq-definitions-backup` must exist.
3. Jenkins host IAM role must allow PutObject to that bucket.

This is separate from the Terraform stack under `Terraform/10-data/rabbitmq-backup/`
and from the Terraform apply job `terraform-rabbitmq`.

---

## 6. How to run a deployment

### Plan-only run (safe; no changes to infrastructure)

1. Go to the Jenkins job (e.g., `terraform-rds`)
2. Click **Build with Parameters**
3. Select `TERRAFORM_ENV` and `CLUSTER_NAME` (or `APP_NAME` + `SERVICE_NAME` for ECS)
4. Leave `RUN_APPLY` **unticked**
5. Click **Build**
6. When the build finishes, open the build → **Artifacts** → download `plan_summary.txt`
7. Review what Terraform intends to change

### Apply run (makes real changes)

1. Repeat steps 1-4 above but **tick `RUN_APPLY`**
2. Click **Build**
3. The pipeline runs Init → Plan → then **pauses** at the Approval Gate
4. Click the build number → open the **Console Output** or the paused stage banner
5. Click **Apply ✅** to proceed (or **Abort** to cancel)
6. Terraform applies the saved plan; there is no drift between what was reviewed and what runs

> **Important:** The apply always uses the binary `tfplan` produced in the same build's Plan
> stage. It is impossible for the plan and apply to diverge.

---

## 7. Parameter summary by job

| Job | Defined in Jenkinsfile | Must add in Jenkins UI |
|---|---|---|
| `terraform-ecs` | *(nothing; no parameters {} in Jenkinsfile)* | All six: `GIT_REPO_URL`, `GIT_BRANCH`, `TERRAFORM_ENV`, `RUN_APPLY`, `APP_NAME`, `SERVICE_NAME` (Active Choices) |
| `terraform-rds` | `GIT_REPO_URL`, `GIT_BRANCH`, `TERRAFORM_ENV` (`test`, `prod`), `RUN_APPLY` | `CLUSTER_NAME` (Active Choices Reactive) |
| `terraform-redis` | `GIT_REPO_URL`, `GIT_BRANCH`, `TERRAFORM_ENV` (`test`, `prod`), `RUN_APPLY` | `CLUSTER_NAME` (Active Choices Reactive) |
| `terraform-rabbitmq` | `GIT_REPO_URL`, `GIT_BRANCH`, `TERRAFORM_ENV` (`test`, `prod`), `RUN_APPLY` | *(nothing)* |
| `terraform-alb` | `GIT_REPO_URL`, `GIT_BRANCH`, `ALB_STACK`, `TERRAFORM_ENV`, `RUN_APPLY` | *(nothing)*; set `APPROVERS` in Jenkinsfile |
| `terraform-vpc` | `GIT_REPO_URL`, `GIT_BRANCH`, `VPC_STACK`, `TERRAFORM_ENV`, `RUN_APPLY` | *(nothing)*; set `APPROVERS` in Jenkinsfile |
| `terraform-drift-detection` | `GIT_REPO_URL`, `GIT_BRANCH` | *(nothing)* |
| `terraform-state-backup` | *(none)* | *(nothing)* |
| `terraform-rabbitmq-backup` | *(none)* | *(nothing)*; requires credential `rmq-zeus-admin` |

---

## 8. Shared helper reference (`terraform_common.groovy`)

| Function | What it does |
|---|---|
| `ensureTools()` | Bootstraps tflint/Trivy into `${WORKSPACE}/.jenkins-tools/bin` (auto-download if missing) |
| `runQualityGatesPreInit(path)` | validateWorkspace, fmt -check, backend key, no-profile, lock file |
| `runQualityGatesPostInit(path, credId)` | validate, tflint, Trivy scan |
| `tfInit(path, credId)` | `terraform init -input=false -lockfile=readonly` |
| `tfPlan(path, credId)` | Plan with `-out=tfplan`, writes `plan_summary.txt` |
| `tfPlanDetailed(path, credId)` | Plan with `-detailed-exitcode` (drift job) |
| `policyCheck(path)` | Returns destroy/replace lines from plan summary |
| `snapshotStateBeforeApply(path, buildNum, credId)` | Copies state to backup bucket before apply |
| `tfApply(path, credId)` | Applies saved `tfplan` |
| `approvalGate(msg, timeoutMin, submitters)` | Human approval; optional submitter restriction |
| `archivePlanArtifacts(path)` | Archives `tfplan` + `plan_summary.txt` |
| `tfDestroy(path, credId)` | Destroy; only after explicit approval gate |

Pinned tool versions (in `terraform_common.groovy`): tflint `0.63.1`, Trivy `0.72.0`.

---

## 9. Validation, security scans, and rollback

There is no separate unit/integration test suite in this repository. Validation is the
Jenkins quality-gate path (fmt, validate, tflint, Trivy, policy check) plus scheduled
drift detection.

| Artifact / location | Purpose |
|---|---|
| `plan_summary.txt` / `tfplan` | Review intended changes before apply; apply uses the same `tfplan` |
| `drift_report.txt` | Daily drift matrix results (Section 5.7) |
| Pre-apply snapshots | Copied to `s3://plat-terraform-state-backup/pre-apply-snapshots/<build>/...` before apply |
| Daily state sync | Full mirror of live state into `plat-terraform-state-backup` (Section 5.8) |

Security scan policy:

- Repo-root [`.tflint.hcl`](../.tflint.hcl) configures TFLint (including the AWS ruleset).
- Repo-root [`.trivyignore`](../.trivyignore) lists accepted Trivy findings with justification.
  HIGH/CRITICAL findings not listed there fail the post-init gate.
- Do not add ignore entries without a review note in `.trivyignore`.

Rollback of a bad apply is not automated in-pipeline. Use the pre-apply snapshot and/or
the daily state backup bucket, then restore state and re-plan carefully.

---
