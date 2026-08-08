/**
 * terraform_common.groovy
 *
 * Reusable Terraform pipeline helpers - loaded into each Jenkinsfile via:
 *   def tf = load 'jenkins/shared/terraform_common.groovy'
 *
 * Requirements:
 *   - Jenkins credentials ID for AWS: 'AWS_SESSION_TOKEN'
 *   - Jenkins credentials ID for Git: 'git-grafana'
 *   - Terraform tool named 'terraform-1.15.5' configured in Jenkins
 *   - Agent: curl, unzip, tar; outbound HTTPS to GitHub (or pre-install tflint/Trivy on PATH)
 *   - Pinned tool versions: tflint 0.63.1, Trivy 0.72.0 (see TFLINT_VERSION / TRIVY_VERSION below)
 *   - Tool install paths resolved at runtime via toolCacheDir() (not at load time)
 */

import groovy.transform.Field
import com.cloudbees.groovy.cps.NonCPS

// Pinned third-party tool versions (linux_amd64 Jenkins agents)
@Field def TFLINT_VERSION = '0.63.1'
@Field def TRIVY_VERSION  = '0.72.0'

// One state bucket per environment, so a prod apply cannot touch test state and
// the two can carry different bucket policies and IAM.
//
// This is a LIST rather than a single value on purpose: the previous single-bucket
// assertion meant any environment on its own bucket failed the pre-init gate,
// which is the "known limitation" the README used to document.
@Field def EXPECTED_BACKEND_BUCKETS = [
    'plat-test-terraform-state',
    'plat-prod-terraform-state',
]

@Field def EXPECTED_BACKEND = [
    region        : 'ap-southeast-1',
    dynamodb_table: 'terraform-state-locking',
]

@Field def STATE_BACKUP_BUCKET = 'plat-terraform-state-backup'

// ──────────────────────────────────────────────────────────
// Tool bootstrap
// ──────────────────────────────────────────────────────────

def toolCacheDir() {
    return "${env.WORKSPACE}/.jenkins-tools"
}

def ensureTools() {
    def cacheDir = toolCacheDir()
    sh """#!/bin/bash
        set -euo pipefail
        mkdir -p '${cacheDir}/bin'
        export PATH='${cacheDir}/bin':\$PATH

        if ! command -v tflint >/dev/null 2>&1; then
            echo "[INFO] Installing tflint v${TFLINT_VERSION}..."
            curl -fsSL "https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip" \\
                -o /tmp/tflint.zip
            unzip -qo /tmp/tflint.zip -d '${cacheDir}/bin'
            chmod +x '${cacheDir}/bin/tflint'
        fi

        if ! command -v trivy >/dev/null 2>&1; then
            echo "[INFO] Installing trivy v${TRIVY_VERSION}..."
            curl -fsSL "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz" \\
                | tar -xz -C '${cacheDir}/bin' trivy
            chmod +x '${cacheDir}/bin/trivy'
        fi

        tflint --version
        trivy --version
    """
    env.PATH = "${cacheDir}/bin:${env.PATH}"
}

// ──────────────────────────────────────────────────────────
// Path validation
// ──────────────────────────────────────────────────────────

def validateWorkspace(String basePath, List<String> requiredFiles = ['main.tf', 'backend.tf', 'terraform.tfvars', 'providers.tf']) {
    if (!fileExists(basePath)) {
        error("Terraform directory not found: ${basePath}")
    }
    requiredFiles.each { f ->
        if (!fileExists("${basePath}/${f}")) {
            error("Missing required file: ${basePath}/${f}")
        }
    }
    echo "✅ Workspace validated: ${basePath}"
}

// ──────────────────────────────────────────────────────────
// Quality gates - pre-init
// ──────────────────────────────────────────────────────────

def tfFmtCheck(String basePath) {
    sh """#!/bin/bash
        set -euo pipefail
        echo "[GATE] terraform fmt -check..."
        terraform fmt -check -diff -recursive '${basePath}'
    """
    echo "✅ fmt check passed: ${basePath}"
}

@NonCPS
def firstMatch(String text, String pattern) {
    def matcher = text =~ pattern
    return matcher.find() ? matcher.group(1) : null
}

def parseBackendKey(String basePath) {
    def backendFile = readFile("${basePath}/backend.tf")
    def key = firstMatch(backendFile, /key\s*=\s*"([^"]+)"/)
    if (!key) {
        error("backend.tf in ${basePath} is missing a key attribute")
    }
    return key
}

def backendKeyCheck(String basePath) {
    def backendFile = readFile("${basePath}/backend.tf")
    def bucket = firstMatch(backendFile, /bucket\s*=\s*"([^"]+)"/)
    def region = firstMatch(backendFile, /region\s*=\s*"([^"]+)"/)
    def dynamodbTable = firstMatch(backendFile, /dynamodb_table\s*=\s*"([^"]+)"/)
    def encrypt = firstMatch(backendFile, /encrypt\s*=\s*(true|false)/)

    if (!bucket || !(bucket in EXPECTED_BACKEND_BUCKETS)) {
        error("backend.tf bucket must be one of ${EXPECTED_BACKEND_BUCKETS.join(', ')} in ${basePath}")
    }

    // A prod state key belongs in the prod bucket and nowhere else. Without this
    // an environment could be pointed at the other environment's state and still
    // pass the bucket check above.
    def keyForBucket = firstMatch(backendFile, /key\s*=\s*"([^"]+)"/)
    if (keyForBucket?.startsWith('prod/') && bucket != 'plat-prod-terraform-state') {
        error("backend.tf key '${keyForBucket}' is a prod key but bucket is '${bucket}' in ${basePath}")
    }
    if (keyForBucket?.startsWith('test/') && bucket != 'plat-test-terraform-state') {
        error("backend.tf key '${keyForBucket}' is a test key but bucket is '${bucket}' in ${basePath}")
    }
    if (!region || region != EXPECTED_BACKEND.region) {
        error("backend.tf region must be '${EXPECTED_BACKEND.region}' in ${basePath}")
    }
    if (!dynamodbTable || dynamodbTable != EXPECTED_BACKEND.dynamodb_table) {
        error("backend.tf dynamodb_table must be '${EXPECTED_BACKEND.dynamodb_table}' in ${basePath}")
    }
    if (!encrypt || encrypt != 'true') {
        error("backend.tf encrypt must be true in ${basePath}")
    }

    def key = parseBackendKey(basePath)
    if (!key?.trim()) {
        error("backend.tf key must not be empty in ${basePath}")
    }

    // Repo-wide duplicate state key scan
    def keysSeen = [:]
    def duplicates = []
    def backendFiles = sh(
        script: "find Terraform -name backend.tf -type f 2>/dev/null || true",
        returnStdout: true
    ).trim().split('\n').findAll { it }

    backendFiles.each { bf ->
        def content = readFile(bf)
        def k = firstMatch(content, /key\s*=\s*"([^"]+)"/)
        if (k) {
            if (keysSeen.containsKey(k)) {
                duplicates << "${k} (${keysSeen[k]} and ${bf})"
            } else {
                keysSeen[k] = bf
            }
        }
    }

    if (duplicates) {
        error("Duplicate backend.tf state keys detected:\n${duplicates.join('\n')}")
    }

    echo "✅ backend key check passed: ${basePath} (key=${key})"
}

def noProviderProfileCheck(String basePath) {
    def tfFiles = sh(
        script: "find '${basePath}' -maxdepth 1 -name '*.tf' -type f 2>/dev/null || true",
        returnStdout: true
    ).trim().split('\n').findAll { it }

    tfFiles.each { tfFile ->
        readFile(tfFile).readLines().each { line ->
            if (line =~ /^\s*profile\s*=/) {
                error("Provider profile usage is not allowed in ${tfFile}. Use Jenkins/AWS env credentials instead.")
            }
        }
    }
    echo "✅ no provider profile check passed: ${basePath}"
}

def providerLockCheck(String basePath) {
    if (!fileExists("${basePath}/.terraform.lock.hcl")) {
        error("Missing .terraform.lock.hcl in ${basePath}. Run scripts/generate-lockfiles.sh and commit the lock file.")
    }
    echo "✅ provider lock file present: ${basePath}"
}

def runQualityGatesPreInit(String basePath) {
    validateWorkspace(basePath)
    tfFmtCheck(basePath)
    backendKeyCheck(basePath)
    noProviderProfileCheck(basePath)
    providerLockCheck(basePath)
}

// ──────────────────────────────────────────────────────────
// Quality gates - post-init
// ──────────────────────────────────────────────────────────

def tfValidate(String basePath, String awsCredId = 'AWS_SESSION_TOKEN') {
    dir(basePath) {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: awsCredId]]) {
            sh '''
                export AWS_DEFAULT_REGION=ap-southeast-1
                terraform validate
            '''
        }
    }
    echo "✅ terraform validate passed: ${basePath}"
}

def tfLintCheck(String basePath) {
    ensureTools()
    def cacheDir = toolCacheDir()
    sh """#!/bin/bash
        set -euo pipefail
        export PATH='${cacheDir}/bin':\$PATH
        echo "[GATE] tflint..."
        tflint --init --config="\${WORKSPACE}/.tflint.hcl" 2>/dev/null || tflint --init
        tflint --config="\${WORKSPACE}/.tflint.hcl" --chdir='${basePath}'
    """
    echo "✅ tflint passed: ${basePath}"
}

def trivyScan(String basePath) {
    ensureTools()
    def cacheDir = toolCacheDir()
    sh """#!/bin/bash
        set -euo pipefail
        export PATH='${cacheDir}/bin':\$PATH
        echo "[GATE] trivy config scan..."
        trivy config \\
            --severity HIGH,CRITICAL \\
            --exit-code 1 \\
            --ignorefile "\${WORKSPACE}/.trivyignore" \\
            '${basePath}'
    """
    echo "✅ trivy scan passed: ${basePath}"
}

def runQualityGatesPostInit(String basePath, String awsCredId = 'AWS_SESSION_TOKEN') {
    tfValidate(basePath, awsCredId)
    tfLintCheck(basePath)
    trivyScan(basePath)
}

// ──────────────────────────────────────────────────────────
// Terraform operations
// ──────────────────────────────────────────────────────────

def tfInit(String basePath, String awsCredId = 'AWS_SESSION_TOKEN') {
    dir(basePath) {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: awsCredId]]) {
            sh '''
                export AWS_DEFAULT_REGION=ap-southeast-1
                terraform --version
                terraform init -input=false -lockfile=readonly
            '''
        }
    }
}

def tfPlan(String basePath, String awsCredId = 'AWS_SESSION_TOKEN') {
    dir(basePath) {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: awsCredId]]) {
            sh '''
                export AWS_DEFAULT_REGION=ap-southeast-1
                terraform plan -var-file=terraform.tfvars -out=tfplan -input=false
                echo "=========== PLAN SUMMARY ==========="
                terraform show -no-color tfplan | tee plan_summary.txt
            '''
        }
    }
}

/**
 * Plan with -detailed-exitcode for drift detection.
 * Returns: 0 = no changes, 1 = error, 2 = drift/changes detected
 */
def tfPlanDetailed(String basePath, String awsCredId = 'AWS_SESSION_TOKEN') {
    def exitCode = 0
    dir(basePath) {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: awsCredId]]) {
            exitCode = sh(
                script: '''
                    export AWS_DEFAULT_REGION=ap-southeast-1
                    set +e
                    terraform plan -var-file=terraform.tfvars -input=false -detailed-exitcode -lock=false
                    echo $?
                ''',
                returnStdout: true
            ).trim().split('\n').last().toInteger()
        }
    }
    return exitCode
}

def tfApply(String basePath, String awsCredId = 'AWS_SESSION_TOKEN') {
    dir(basePath) {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: awsCredId]]) {
            sh '''
                export AWS_DEFAULT_REGION=ap-southeast-1
                terraform apply -input=false tfplan
            '''
        }
    }
}

def tfDestroy(String basePath, String awsCredId = 'AWS_SESSION_TOKEN') {
    dir(basePath) {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: awsCredId]]) {
            sh 'terraform destroy -var-file=terraform.tfvars -input=false -auto-approve'
        }
    }
}

// ──────────────────────────────────────────────────────────
// Policy check
// ──────────────────────────────────────────────────────────

/**
 * Parse plan_summary.txt for destructive actions.
 * Returns list of matching lines (empty if none).
 */
def policyCheck(String basePath) {
    def summaryPath = "${basePath}/plan_summary.txt"
    if (!fileExists(summaryPath)) {
        echo "⚠️  No plan_summary.txt found - skipping policy check"
        return []
    }
    def summary = readFile(summaryPath)
    def destructive = []
    summary.readLines().each { line ->
        if (line =~ /will be destroyed|must be replaced/) {
            destructive << line.trim()
        }
    }
    if (destructive) {
        echo "⚠️  POLICY: ${destructive.size()} destructive action(s) detected:"
        destructive.each { echo "   ${it}" }
    } else {
        echo "✅ policy check: no destroy/replace actions in plan"
    }
    return destructive
}

// ──────────────────────────────────────────────────────────
// State snapshot (rollback support)
// ──────────────────────────────────────────────────────────

def snapshotStateBeforeApply(String basePath, String buildNumber, String awsCredId = 'AWS_SESSION_TOKEN') {
    def stateKey = parseBackendKey(basePath)
    def snapshotKey = "pre-apply-snapshots/${buildNumber}/${stateKey}"
    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: awsCredId]]) {
        sh """#!/bin/bash
            set -euo pipefail
            export AWS_DEFAULT_REGION=ap-southeast-1
            SRC="s3://${EXPECTED_BACKEND.bucket}/${stateKey}"
            DST="s3://${STATE_BACKUP_BUCKET}/${snapshotKey}"
            echo "[INFO] Snapshotting state: \${SRC} -> \${DST}"
            if aws s3api head-object --bucket '${EXPECTED_BACKEND.bucket}' --key '${stateKey}' 2>/dev/null; then
                aws s3 cp "\${SRC}" "\${DST}" --sse AES256
                echo "[INFO] State snapshot saved to \${DST}"
            else
                echo "[WARN] No existing state object at \${SRC} - skipping snapshot (first apply?)"
            fi
        """
    }
}

// ──────────────────────────────────────────────────────────
// Approval gate
// ──────────────────────────────────────────────────────────

def approvalGate(String message, int timeoutMinutes = 30, String submitters = '') {
    timeout(time: timeoutMinutes, unit: 'MINUTES') {
        def inputParams = [
            message: message,
            ok     : 'Apply ✅',
        ]
        if (submitters?.trim()) {
            inputParams.submitter = submitters.trim()
            inputParams.submitterParameter = 'APPROVED_BY'
        } else {
            inputParams.submitter = ''
            inputParams.submitterParameter = 'APPROVED_BY'
        }
        input(inputParams)
    }
}

// ──────────────────────────────────────────────────────────
// Post-stage helpers
// ──────────────────────────────────────────────────────────

def archivePlanArtifacts(String basePath) {
    archiveArtifacts(
        artifacts: "${basePath}/tfplan, ${basePath}/plan_summary.txt",
        allowEmptyArchive: true
    )
}

return this
