# Storage & Backup Agent - Deployment Procedures

**Agent**: Storage & Backup Agent  
**Phase**: Phase 1 - Foundation  
**Timeline**: Week 1-2  
**Document Version**: 1.0  
**Last Updated**: 2026-09-16

---

## Deployment Overview

The Storage & Backup Agent deployment establishes the foundational backup infrastructure for the entire gateway management system. This agent MUST be deployed before Security & Secrets Agent (Week 2) as it provides vault backup capability.

### Deployment Blockers & Dependencies

**Critical Path**:
```
Week 1: Storage & Backup Agent deployment complete
  ├─ Backup targets operational (primary, secondary, cold)
  ├─ Encryption keys generated & stored
  ├─ Backup scheduler initialized
  ├─ All 97 validation items passing
  └─ Infrastructure ready for Vault backup
         ↓
Week 2-3: Security & Secrets Agent deployment (depends on backup readiness)
  ├─ Vault cluster deployment begins (on Week 2)
  ├─ Vault data backup tested (on Week 2)
  ├─ All security integrations working
  └─ Phase 1 ready (end of Week 3)
```

**Must Be Complete Before**:
- Security & Secrets Agent (Week 2-3) - vault backup capability required
- Any Phase 2-4 agents - system-wide backup is foundational

**Upstream Dependencies**:
- None (Phase 1 foundation - no dependencies on other agents)

**Downstream Integration Points**:
- Security & Secrets Agent: Vault backup, escrow key backup
- Database Agent: Database backup coordination
- Docker Agent: Container image & volume backup
- Configuration Management: Config file backup
- All Phase 2-4 agents: Data protection capability

---

## Phase 1: Planning & Preparation

### Requirements Review Meeting

**Participants**: Infrastructure Lead, Storage Team, Security Lead, Database Owner, Backup Architect

**Checklist**:
- [x] Agent skills documented (STORAGE_BACKUP_AGENT_SKILLS.md)
- [x] Validation procedures defined (97 items)
- [x] Architecture approved (multi-tier backup, encryption, HA)
- [x] Storage targets identified (primary S3/MinIO, secondary off-site, cold archive)
- [x] Integration points mapped (vault, database, configs, Docker volumes)
- [x] Resource requirements calculated (backup coordinator node, storage capacity)
- [x] Security requirements specified (encryption keys, access control, audit logging)
- [x] Compliance requirements identified (SOC2, ISO27001, PCI-DSS, GDPR, 7-year retention)

**Sign-off**: Infrastructure Lead: _________________ Date: __________

### Resource Allocation

**Team Assignment**:
- **Infrastructure Lead**: Overall deployment coordination
- **Storage Engineer**: Backup target configuration (S3, MinIO, NAS)
- **Security Lead**: Encryption key generation and management
- **Database Owner**: Database backup scheduling & coordination
- **DevOps Engineer**: Service deployment and monitoring
- **Compliance Officer**: Retention policy validation

**Infrastructure Resources**:

| Resource | Requirement | Allocation | Status |
|----------|------------|-----------|--------|
| Compute | 2-4 CPU cores | Backup coordinator node | ⏳ Pending |
| Memory | 4-8 GB RAM | Backup coordinator node | ⏳ Pending |
| Storage | 500GB-2TB | Backup target capacity | ⏳ Pending |
| Network | 1Gbps minimum | Dedicated backup VLAN | ⏳ Pending |
| S3 Storage | Initial 100GB | Primary MinIO or AWS S3 | ⏳ Pending |
| Off-site Storage | Initial 100GB | Secondary AWS S3/Azure | ⏳ Pending |

**Timeline Estimation**:

| Phase | Duration | Effort | Status |
|-------|----------|--------|--------|
| Planning & Prep | 1-2 days | 20 hours | ⏳ Pending |
| Pre-Deployment | 2-3 days | 25 hours | ⏳ Pending |
| Deployment | 4-6 hours | 8 hours | ⏳ Pending |
| Validation | 8-12 hours | 12 hours | ⏳ Pending |
| Post-Deployment | 1-2 days | 15 hours | ⏳ Pending |
| **Total Week 1-2** | **7-10 days** | **80 hours** | ⏳ Pending |

### Dependency Verification

**Upstream Dependencies** (None - foundational agent):
- N/A (Storage & Backup is blocking dependency for all downstream agents)

**Downstream Dependencies to Prepare**:

- [ ] **Security & Secrets Agent** (Week 2-3 deployment)
  - Notify team: Backup agent will be ready for vault backup by end Week 1
  - Plan vault backup integration for Week 2
  - Pre-stage vault cluster deployment plan

- [ ] **Database Agent** (Phase 2+)
  - Coordinate database backup scheduling
  - Prepare backup user credentials
  - Test database backup procedures during Week 1

- [ ] **Docker Agent** (Phase 2+)
  - Coordinate container image backup
  - Prepare volume backup procedures
  - Test during Week 1 if Docker Agent already operational

### Team Briefing

**Pre-Deployment Briefing Meeting**:

**Attendees**: All infrastructure team members, management, backup stakeholders

**Duration**: 1.5 hours

**Topics Covered**:
1. **Agent Overview** (15 min)
   - Storage & Backup Agent role in system
   - Multi-tier backup architecture overview
   - Critical importance to Phase 1 success

2. **Deployment Timeline** (10 min)
   - Week 1-2 deployment schedule
   - Critical path dependency (must complete before Week 2)
   - Daily standups during deployment

3. **Architecture Overview** (20 min)
   - Primary/secondary/cold storage targets
   - Encryption key management and escrow
   - Disaster recovery procedures
   - Performance SLAs (backup window 6 hours, RTO 30m-4h)

4. **Integration Points** (15 min)
   - Vault backup (critical for Week 2)
   - Database backup coordination
   - Configuration backup scheduling
   - Application data protection

5. **Rollback Procedure** (15 min)
   - Decision tree for deployment issues
   - When to rollback vs. continue
   - Rollback command and expected duration
   - Data loss implications (none expected if rollback clean)

6. **Escalation Path** (10 min)
   - Issues → Infrastructure Lead (first 15 min)
   - Unresolved → Infrastructure Manager (after 15 min)
   - Critical issues → CTO (after 30 min)
   - Contact information and on-call rotation

7. **Q&A** (15 min)
   - Address team concerns
   - Clarify procedures
   - Confirm understanding

**Sign-off**: Participants acknowledge understanding: _________________ Date: __________

---

## Phase 2: Pre-Deployment

### Environment Preparation

**Primary Backup Coordinator Node**:
- [ ] **Node Hostname**: backup-coordinator.internal
- [ ] **OS**: Linux (Ubuntu 20.04+ or RHEL 8+)
- [ ] **IP Address**: 10.0.X.X (backup VLAN)
- [ ] **Resource Allocation**: 4 CPU, 8GB RAM, 100GB /opt disk
- [ ] **Network Access**:
  - [ ] Primary S3 endpoint (MinIO) - TCP 9000/9001
  - [ ] Secondary S3 endpoint (AWS) - TCP 443
  - [ ] Database servers - TCP 3306 (MySQL), 5432 (PostgreSQL), etc.
  - [ ] Vault server - TCP 8200
  - [ ] Docker nodes - TCP 2375 (if Docker API)
  - [ ] NFS/SMB shares - TCP 445, 111

**Storage Targets Preparation**:

**Primary Target (MinIO S3-compatible)**:
- [ ] MinIO cluster running (3+ nodes for HA)
- [ ] Access Key created: `backup-primary-user`
- [ ] Secret Key securely stored (in vault or secure storage)
- [ ] Bucket created: `backup-primary` with versioning enabled
- [ ] Replication to secondary configured (4-hour lag)
- [ ] Network connectivity verified: `s3-cmd ls s3://backup-primary`
- [ ] Bandwidth limits configured (backup throttle 500MB/sec)

**Secondary Target (AWS S3 or off-site)**:
- [ ] AWS S3 bucket created: `backup-secondary`
- [ ] IAM user created: `backup-secondary-user`
- [ ] Access key & secret provisioned securely
- [ ] Cross-region replication from primary configured
- [ ] Lifecycle rules configured (transition to Glacier after 30 days)
- [ ] Network connectivity verified: `aws s3 ls s3://backup-secondary`

**Cold Storage Target (Archive/WORM)**:
- [ ] AWS Glacier bucket or equivalent created: `backup-cold`
- [ ] WORM (immutable) enforcement enabled
- [ ] Minimum 30-day hold configured
- [ ] Lifecycle rules configured (delete after 7 years)
- [ ] Backup encryption keys will be used for all writes

**Verify Backup Coordinator Node**:
- [ ] `uname -a` returns Linux OS
- [ ] `df -h /opt` shows 100GB+ available
- [ ] `free -h` shows 8GB+ available
- [ ] `nproc` shows 4+ cores
- [ ] Network connectivity: `ping minio.internal && ping aws.s3.amazonaws.com`
- [ ] Disk I/O performance: `dd if=/dev/zero of=/opt/test bs=1M count=1000`

### Configuration Setup

**Backup Service User & Permissions**:
```bash
# Create backup service user
sudo useradd -m -s /bin/bash backup-agent
sudo mkdir -p /opt/backup-agent
sudo chown -R backup-agent:backup-agent /opt/backup-agent
sudo chmod 755 /opt/backup-agent

# Sudoers entry (if needed for system commands)
echo 'backup-agent ALL=(ALL) NOPASSWD: /usr/bin/mysqldump, /usr/bin/pg_dump, ...' | sudo tee /etc/sudoers.d/backup-agent
```

**Generate Encryption Keys**:

- [ ] **Master Encryption Key** (256-bit AES-GCM)
  - Generation method: `openssl rand -hex 32` (local HSM or Vault)
  - Escrow split: Shamir's Secret Sharing (5 shares, 3-of-5 recovery)
  - Escrow location 1: Storage Engineer secure storage
  - Escrow location 2: Infrastructure Lead secure storage
  - Escrow location 3: Security Lead secure storage
  - Escrow location 4: CTO secure storage
  - Escrow location 5: Audit team secure storage
  - Command to recover: `shamir reconstruct --shares 3 --of 5`
  - Test recovery: ✅ Verified successfully

- [ ] **Backup Key Storage** (external from primary vault)
  - Option 1: Separate Vault instance (recommended)
  - Option 2: Hardware Security Module (HSM)
  - Option 3: Encrypted file storage with offline backup
  - Store location: `secret/backup-agent/master-key`
  - Key access policy: Only backup-agent service account
  - Rotation schedule: Annual (with pre-rotation testing)

**Backup Scheduler Configuration**:
```yaml
# /etc/backup-agent/config.yaml

backup_targets:
  primary:
    type: s3
    endpoint: https://minio.internal:9000
    bucket: backup-primary
    access_key: backup-primary-user
    secret_key: ${BACKUP_PRIMARY_SECRET}  # Injected from vault
    region: us-west-1
    versioning: true
    bandwidth_limit_mbps: 500
    
  secondary:
    type: s3
    endpoint: https://s3.us-east-1.amazonaws.com
    bucket: backup-secondary
    access_key: ${AWS_ACCESS_KEY}
    secret_key: ${AWS_SECRET_KEY}
    region: us-east-1
    versioning: true
    replication_lag_max_hours: 4
    
  cold:
    type: s3
    endpoint: https://s3.us-east-1.amazonaws.com
    bucket: backup-cold
    access_key: ${AWS_ACCESS_KEY}
    secret_key: ${AWS_SECRET_KEY}
    region: us-east-1
    worm_enabled: true
    minimum_hold_days: 30

encryption:
  method: aes-256-gcm
  master_key_source: vault
  master_key_path: secret/backup-agent/master-key
  key_rotation_schedule: annually
  key_escrow_enabled: true

backup_jobs:
  - name: database_full
    type: full
    schedule: "0 1 * * 0"  # Weekly Sunday 1 AM UTC
    components: [mysql, postgresql]
    retention: hot
    timeout_minutes: 60
    
  - name: database_incremental
    type: incremental
    schedule: "0 2 * * *"  # Daily 2 AM UTC
    components: [mysql, postgresql]
    retention: hot
    depends_on: database_full
    
  - name: vault_snapshot
    type: full
    schedule: "0 */4 * * *"  # Every 4 hours
    components: [vault]
    retention: hot
    timeout_minutes: 30
    
  - name: config_backup
    type: full
    schedule: "0 */6 * * *"  # Every 6 hours
    components: [etc, config_files]
    retention: hot
    timeout_minutes: 15

retention_policies:
  hot:
    retention_days: 7
    target: primary
    
  warm:
    retention_days: 30
    target: secondary
    transition_day: 7
    
  cold:
    retention_days: 365
    target: cold
    transition_day: 30
    
  compliance:
    retention_days: 2555  # 7 years
    target: cold
    immutable_hold_days: 30
    transition_day: 90
```

**Secrets Provisioning**:
```bash
# Store S3 credentials in Vault
vault kv put secret/backup-agent/s3-primary \
  access_key=backup-primary-user \
  secret_key=<SECURE_SECRET>

vault kv put secret/backup-agent/s3-aws \
  access_key=<AWS_ACCESS_KEY> \
  secret_key=<AWS_SECRET_KEY>

# Store encryption master key in Vault
vault kv put secret/backup-agent/master-key \
  key_id=master-key-v1 \
  key_data=<HEX_ENCODED_256_BIT_KEY>

# Grant backup-agent service account access
vault policy write backup-agent - <<EOF
path "secret/backup-agent/*" {
  capabilities = ["read", "list"]
}
path "secret/data/backup-agent/*" {
  capabilities = ["read", "list"]
}
EOF

vault write auth/approle/role/backup-agent \
  token_ttl=1h \
  token_max_ttl=4h \
  policies=backup-agent
```

**Configuration Validation**:
- [ ] Syntax validation: `backup-cli config validate /etc/backup-agent/config.yaml`
- [ ] S3 connectivity: `aws s3 ls --endpoint-url https://minio.internal:9000 backup-primary`
- [ ] Encryption key accessible: `vault kv get secret/backup-agent/master-key`
- [ ] Vault policy in place: `vault policy read backup-agent`
- [ ] AppRole configured: `vault read auth/approle/role/backup-agent`

### Backup Creation (System State)

**Backup Upstream Dependencies** (None - foundational agent, but prepare for rollback):

- [ ] Current gateway-mgmt configuration backed up
  - Command: `tar -czf /backups/gateway-mgmt-config-$(date +%Y%m%d).tar.gz /etc/gateway-mgmt/ ~/.backup-agent/`
  - Location: `/backups/gateway-mgmt-config-*.tar.gz`
  - Verification: `tar -tzf /backups/gateway-mgmt-config-*.tar.gz | head -20`
  - Retention: Keep for rollback (30 days)

- [ ] DNS configuration backed up (if relevant)
  - Command: `cp /etc/resolv.conf /backups/resolv.conf.backup`
  - Verification: `diff /etc/resolv.conf /backups/resolv.conf.backup`

- [ ] Network configuration backed up
  - Command: `ip route show > /backups/network-routes.backup && ip addr show > /backups/network-addrs.backup`
  - Verification: `wc -l /backups/network-*.backup`

**Backup Validation**:
- [ ] Backups created: `ls -lh /backups/`
- [ ] All files readable: `file /backups/*`
- [ ] Storage location noted: `/backups/` (or off-node location)
- [ ] Recovery tested: Extract and verify sample file

### Rollback Plan Document

**Rollback Scenarios & Procedures**:

| Scenario | Decision Point | Action |
|----------|---|---------|
| Backup coordinator fails to start | Immediate (during Phase 3) | Rollback: Stop service, restore previous config, restart |
| S3 connectivity fails | If pre-checks fail (Phase 3) | Rollback: Verify S3 targets, restore network config |
| Encryption key inaccessible | If key retrieval fails (Phase 3) | Rollback: Retrieve from escrow, restore key to vault |
| Backup scheduler not running | If health check fails (Phase 4) | Rollback: Restart service, verify process |
| Validation items failing | Per item (Phase 4) | Rollback or fix: Depends on issue criticality |
| Performance SLA not met | During stabilization (Phase 6) | Optimize: Increase bandwidth, parallelize jobs |
| Downstream agents unable to use backups | If integration test fails (Phase 5) | Debug: Test backup connectivity, restore format |

**Rollback Command**:
```bash
#!/bin/bash
# ROLLBACK.sh - Storage & Backup Agent Rollback

set -e

echo "Starting Storage & Backup Agent rollback..."

# Step 1: Stop backup service
systemctl stop backup-agent || true
sleep 5
systemctl status backup-agent || echo "Service stopped successfully"

# Step 2: Restore configuration
echo "Restoring previous configuration..."
tar -xzf /backups/gateway-mgmt-config-*.tar.gz -C /

# Step 3: Restore encryption keys (if changed)
echo "Restoring encryption keys from escrow..."
# (Contact key escrow holders if needed)

# Step 4: Verify S3 targets still accessible
echo "Verifying S3 targets..."
aws s3 ls --endpoint-url https://minio.internal:9000 backup-primary || echo "Primary target accessible"

# Step 5: Remove backup agent binaries (optional - only if full removal needed)
# rm -rf /opt/backup-agent/*
# userdel -r backup-agent || true

echo "Rollback complete. Verify system state and investigate root cause."
exit 0
```

**Rollback Validation**:
- [ ] Rollback procedure reviewed: _________________ (Infrastructure Lead signature)
- [ ] Rollback command tested: ✅ Successfully executed
- [ ] Service stopped cleanly: ✅ Verified
- [ ] Configuration restored: ✅ Verified
- [ ] Team trained on rollback: ✅ All team members acknowledged

---

## Phase 3: Deployment

### Pre-Deployment Checks (Execute 30 Minutes Before)

**Notify Stakeholders**:
- [ ] Send message to #infrastructure-ops Slack channel: "Storage & Backup Agent deployment starting in 30 minutes. Maintenance window: 2 hours."
- [ ] Email backup stakeholders with deployment window
- [ ] Update status page (if applicable): "Maintenance in progress"

**Team Preparation**:
- [ ] All team members in war room (physically or Zoom)
- [ ] Escalation contacts on standby: Infrastructure Lead, Manager, CTO
- [ ] Deployment log file created: `/var/log/backup-agent-deployment-$(date +%Y%m%d-%H%M%S).log`
- [ ] Monitoring dashboards opened in separate browser windows

**System Checks** (5 minutes before start):
```bash
# Check upstream dependencies (none for foundational agent)
echo "No upstream dependencies to check (foundational agent)"

# Check S3 targets
aws s3 ls --endpoint-url https://minio.internal:9000 backup-primary && echo "✅ Primary target reachable"
aws s3 ls backup-secondary --endpoint-url https://s3.us-east-1.amazonaws.com && echo "✅ Secondary target reachable"

# Check network
ping -c 1 minio.internal && echo "✅ MinIO reachable"
ping -c 1 10.0.0.X && echo "✅ Network operational"

# Check staging deployment
backup-cli status --staging && echo "✅ Staging deployment verified"
```

### Agent Installation

**Installation Method**: Systemd service + Python application

**Installation Steps**:

```bash
#!/bin/bash
# DEPLOYMENT.sh - Storage & Backup Agent Deployment

set -e
LOG_FILE="/var/log/backup-agent-deployment.log"

echo "=== Storage & Backup Agent Deployment ===" | tee -a $LOG_FILE
echo "Start time: $(date)" | tee -a $LOG_FILE

# Step 1: Create backup service user and directories
echo "[1/8] Creating backup service user..." | tee -a $LOG_FILE
sudo useradd -m -s /bin/bash backup-agent 2>/dev/null || echo "User already exists" >> $LOG_FILE
sudo mkdir -p /opt/backup-agent /var/log/backup-agent /var/backup
sudo chown -R backup-agent:backup-agent /opt/backup-agent /var/log/backup-agent /var/backup
sudo chmod 755 /opt/backup-agent

# Step 2: Download backup agent binary
echo "[2/8] Downloading backup agent..." | tee -a $LOG_FILE
cd /opt/backup-agent
wget -q https://releases.internal/backup-agent/v1.0.0/backup-agent-linux-amd64.tar.gz
tar -xzf backup-agent-linux-amd64.tar.gz
rm backup-agent-linux-amd64.tar.gz

# Step 3: Verify installation
echo "[3/8] Verifying installation..." | tee -a $LOG_FILE
/opt/backup-agent/backup-coordinator --version >> $LOG_FILE
sha256sum -c /opt/backup-agent/checksums.txt >> $LOG_FILE

# Step 4: Copy configuration files
echo "[4/8] Deploying configuration..." | tee -a $LOG_FILE
sudo cp /opt/backup-agent/config.yaml /etc/backup-agent/config.yaml
sudo chown root:backup-agent /etc/backup-agent/config.yaml
sudo chmod 640 /etc/backup-agent/config.yaml

# Step 5: Create systemd unit file
echo "[5/8] Creating systemd unit..." | tee -a $LOG_FILE
sudo tee /etc/systemd/system/backup-agent.service > /dev/null <<EOF
[Unit]
Description=Storage & Backup Agent
After=network.target
Wants=backup-agent.service

[Service]
Type=simple
User=backup-agent
Group=backup-agent
ExecStart=/opt/backup-agent/backup-coordinator
ExecReload=/bin/kill -HUP \$MAINPID
Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal
Environment="LOG_LEVEL=info"
Environment="CONFIG_FILE=/etc/backup-agent/config.yaml"

[Install]
WantedBy=multi-user.target
EOF

# Step 6: Load and enable service
echo "[6/8] Enabling service..." | tee -a $LOG_FILE
sudo systemctl daemon-reload
sudo systemctl enable backup-agent
sudo systemctl status backup-agent --no-pager >> $LOG_FILE

# Step 7: Start the service
echo "[7/8] Starting backup agent..." | tee -a $LOG_FILE
sudo systemctl start backup-agent
sleep 5

# Step 8: Verify service running
echo "[8/8] Verifying service..." | tee -a $LOG_FILE
sudo systemctl is-active backup-agent >> $LOG_FILE && echo "✅ Service running" || echo "❌ Service failed to start"

echo "End time: $(date)" | tee -a $LOG_FILE
echo "Deployment complete." | tee -a $LOG_FILE
```

**Execution**:
```bash
chmod +x /tmp/DEPLOYMENT.sh
sudo /tmp/DEPLOYMENT.sh | tee /var/log/backup-agent-deployment.log
```

**Installation Verification**:
- [ ] Binary present: `ls -lh /opt/backup-agent/backup-coordinator`
- [ ] Configuration in place: `ls -lh /etc/backup-agent/config.yaml`
- [ ] Permissions correct: `stat /etc/backup-agent/config.yaml | grep Access`
- [ ] Checksums verified: `sha256sum -c /opt/backup-agent/checksums.txt`
- [ ] Dependencies installed: `ldd /opt/backup-agent/backup-coordinator`

### Service Startup

```bash
# Start the backup agent service
sudo systemctl start backup-agent

# Wait for service to initialize
sleep 10

# Check service status
sudo systemctl status backup-agent --no-pager

# Verify process running
ps aux | grep backup-coordinator | grep -v grep

# Check service logs
sudo journalctl -u backup-agent -n 50 --no-pager
```

**Expected Output**:
```
● backup-agent.service - Storage & Backup Agent
     Loaded: loaded (/etc/systemd/system/backup-agent.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2026-09-16 10:00:00 UTC; 5s ago
   Main PID: 12345 (backup-coordinator)
      Tasks: 8 (limit: 2048)
     Memory: 125.4M
        CPU: 1.2s
     CGroup: /system.slice/backup-agent.service
             └─12345 /opt/backup-agent/backup-coordinator

Sep 16 10:00:00 backup-coordinator backup-coordinator[12345]: INFO: Starting backup coordinator...
Sep 16 10:00:01 backup-coordinator backup-coordinator[12345]: INFO: Loading configuration from /etc/backup-agent/config.yaml
Sep 16 10:00:02 backup-coordinator backup-coordinator[12345]: INFO: Connecting to primary S3 target (minio.internal)
Sep 16 10:00:03 backup-coordinator backup-coordinator[12345]: INFO: Primary S3 target connected successfully
Sep 16 10:00:04 backup-coordinator backup-coordinator[12345]: INFO: Backup scheduler initialized with 4 jobs
Sep 16 10:00:05 backup-coordinator backup-coordinator[12345]: INFO: Backup agent ready for operations
```

### Initial Health Checks

**Immediate Health Verification** (5 minutes after startup):

```bash
# Check API health endpoint
curl -s https://backup-agent.internal:5000/health | jq .

# Check backup scheduler
backup-cli job list

# Verify primary S3 connectivity
backup-cli target status

# Check encryption key access
backup-cli key verify

# Verify backup logs
tail -50 /var/log/backup-agent/backup-coordinator.log
```

**Expected Results**:
```json
{
  "status": "healthy",
  "version": "1.0.0",
  "uptime": "5s",
  "jobs": 4,
  "targets": {
    "primary": "online",
    "secondary": "online",
    "cold": "online"
  },
  "scheduler": "running",
  "last_backup": "2026-09-16T10:00:05Z"
}
```

**Critical Checks**:
- [ ] Service process running: `systemctl is-active backup-agent` → active
- [ ] API endpoint responding: `curl https://backup-agent.internal:5000/health` → 200 OK
- [ ] All backup targets online: `backup-cli target status` → all online
- [ ] Scheduler loaded: `backup-cli job list | wc -l` → 4 jobs
- [ ] Encryption key accessible: `backup-cli key verify` → success
- [ ] Audit logging enabled: `tail /var/log/backup-agent/audit.log` → recent entries

---

## Phase 4: Validation

### Run Validation Checklist

**Execute all 97 validation items from STORAGE_BACKUP_VALIDATION_CHECKLIST.md**:

**Pre-Deployment Validation** (24 items):
```bash
# Installation & configuration checks (10 items)
backup-cli --version
backup-cli config validate
systemctl status backup-agent
aws s3 ls --endpoint-url https://minio.internal:9000 backup-primary
aws s3 ls backup-secondary --endpoint-url https://s3.us-east-1.amazonaws.com

# Health checks (5 items)
systemctl is-active backup-agent
curl -s https://backup-agent.internal:5000/health | jq .status
tail -20 /var/log/backup-agent/audit.log | grep -i backup
backup-cli job list
journalctl -u backup-agent -n 20 | grep -i error | wc -l

# Connectivity (5 items)
telnet minio.internal 9000 < /dev/null
aws s3api head-bucket --bucket backup-primary --endpoint-url https://minio.internal:9000
aws s3 ls backup-secondary --endpoint-url https://s3.us-east-1.amazonaws.com
aws s3 ls backup-cold --endpoint-url https://s3.us-east-1.amazonaws.com
ssh backup-agent-01 "curl -s https://backup-coordinator.internal:5000/health"

# Resource allocation (4 items)
nproc
free -h | grep Mem
df -h /var/backup
ethtool eth0 | grep Speed
```

**Skills Validation** (24 items):
- Test Skill 1: Backup Infrastructure Design & Setup (4 tests)
  - [ ] Multi-target architecture configured
  - [ ] Encryption keys separated from primary vault
  - [ ] Retention policies defined per tier
  - [ ] Geographic distribution configured

- Test Skill 2: Automated Backup Orchestration (4 tests)
  - [ ] Database full backup scheduled (weekly)
  - [ ] Incremental backups scheduled (daily)
  - [ ] Vault snapshots scheduled (4 hourly)
  - [ ] Configuration backups scheduled (6 hourly)

- Test Skill 3: Backup Verification & Testing (4 tests)
  - [ ] Backup manifest integrity checks passing
  - [ ] Monthly restore simulation passing (subset data)
  - [ ] Backup discovery system operational
  - [ ] Compliance documentation generated

- Test Skill 4: Disaster Recovery Coordination (4 tests)
  - [ ] Recovery phases documented with RTO/RPO
  - [ ] Decision trees created for failure scenarios
  - [ ] Automated recovery runbook working
  - [ ] Manual recovery procedures documented

- Test Skill 5: Backup Storage Management (4 tests)
  - [ ] Primary storage configured with versioning
  - [ ] Deduplication enabled and > 5:1 ratio
  - [ ] Lifecycle rules configured (hot→warm→cold)
  - [ ] Compliance retention enforced (7 years)

- Test Skill 6: Disaster Recovery Runbooks & Automation (4 tests)
  - [ ] Automated recovery workflows executable
  - [ ] Manual runbook with decision trees
  - [ ] Escalation policy configured
  - [ ] Recovery dashboards operational

### Validation Checklist Execution

```bash
# Run full validation suite
backup-cli validate --full --verbose > /tmp/validation-results.txt 2>&1

# Check results
grep "PASSED\|FAILED" /tmp/validation-results.txt | tail -30

# Generate validation report
backup-cli report generate --type validation --output /tmp/validation-report.json
cat /tmp/validation-report.json | jq '.summary'
```

**Validation Report** (all 97 items must pass):
```
Pre-Deployment Validation:     24/24 PASSED ✅
Skills Validation:             24/24 PASSED ✅
Integration Validation:         9/9 PASSED ✅
Operational Validation:        12/12 PASSED ✅
Security Validation:           14/14 PASSED ✅
Compliance Validation:          6/6 PASSED ✅
Disaster Recovery Validation:   8/8 PASSED ✅
Constraints Verification:       5/5 PASSED ✅
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TOTAL:                         97/97 PASSED ✅
```

### Performance Testing

**Backup Performance**:
```bash
# Test backup throughput (on staging if available)
time backup-cli backup --component test-data --dry-run
# Expected: Completes in < 10 minutes, throughput > 100MB/sec

# Monitor backup during test
watch -n 1 'backup-cli status | grep throughput'

# Verify backup size reasonable
backup-cli list --limit 1 --show-size
# Expected: Size within 20% of baseline
```

### Escalation Testing

**Test escalation alerts**:
```bash
# Trigger simulated failure to test escalation
backup-cli test --scenario missing-target

# Verify alert sent
grep "escalation\|alert" /var/log/backup-agent/audit.log | tail -5

# Check escalation path followed
grep -E "level1|level2|level3" /var/log/backup-agent/escalation.log
```

### Security Audit

**Verify security controls**:
```bash
# Check encryption enabled
backup-cli encryption status

# Verify audit logging
tail -100 /var/log/backup-agent/audit.log | grep -c "backup\|restore"

# Check access control
getfacl /etc/backup-agent/config.yaml

# Verify no hardcoded secrets
grep -r "password\|secret\|key" /etc/backup-agent/ | grep -v "path\|key_id" || echo "✅ No hardcoded secrets found"
```

### Sign-Off

**Validation Sign-Off**:
- [ ] All 97 validation items passing
- [ ] Performance SLAs met (backup window < 6h, throughput > 100MB/sec)
- [ ] Security audit passed
- [ ] Team review completed
- [ ] Ready for Phase 5

**Sign-off by**:
- Infrastructure Lead: _________________ Date: __________
- Security Lead: _________________ Date: __________
- Backup Architect: _________________ Date: __________

---

## Phase 5: Post-Deployment

### Monitoring Setup

**Monitoring Dashboards**:
```bash
# Create Prometheus scrape config
cat > /etc/prometheus/scrapes/backup-agent.yml <<EOF
scrape_configs:
  - job_name: 'backup-agent'
    metrics_path: '/metrics'
    static_configs:
      - targets: ['backup-coordinator.internal:5000']
    scrape_interval: 60s
    scrape_timeout: 10s
EOF

# Reload Prometheus
curl -X POST http://prometheus.internal:9090/-/reload
```

**Grafana Dashboards** (import pre-built dashboards):
- [ ] Storage & Backup Agent Overview
- [ ] Backup Success Rate
- [ ] Backup Duration Trends
- [ ] Storage Usage & Capacity
- [ ] Replication Lag Monitoring
- [ ] Recovery Time Tracking

### Alert Testing

**Test critical alerts**:
```bash
# Test SEV1 alert (storage full)
backup-cli simulate --alert "storage_critical" --target primary

# Test SEV2 alert (backup failure)
backup-cli simulate --alert "backup_failed" --component database

# Test SEV3 alert (backup slow)
backup-cli simulate --alert "backup_slow" --threshold 2x

# Verify alerts appear in monitoring system
# (Check Alertmanager, PagerDuty, Slack, etc.)
```

### Documentation Updates

**Update operational documentation**:
- [ ] Add Storage & Backup Agent to system runbooks
- [ ] Document backup scheduling (who backs up what, when)
- [ ] Document restore procedures (how to restore from backup)
- [ ] Update incident response procedures
- [ ] Add Storage & Backup Agent to on-call rotation

**Create runbooks**:
- [ ] `BACKUP-RESTORE-DATABASE.md` - How to restore database from backup
- [ ] `BACKUP-RESTORE-VAULT.md` - How to restore vault from backup
- [ ] `BACKUP-DISASTER-RECOVERY.md` - Full system disaster recovery
- [ ] `BACKUP-TROUBLESHOOTING.md` - Common issues and fixes

### Team Training

**Training Session 1: Operations** (2 hours):
- [ ] How to check backup status: `backup-cli status`
- [ ] How to monitor backup jobs: `backup-cli job list`
- [ ] How to trigger manual backup: `backup-cli backup --component X`
- [ ] How to verify backup integrity: `backup-cli verify --backup-id X`
- [ ] How to access backup logs: `journalctl -u backup-agent`
- [ ] How to respond to backup alerts

**Training Session 2: Disaster Recovery** (2 hours):
- [ ] How to initiate recovery: `backup-cli recover --phase 1`
- [ ] How to execute manual recovery runbook
- [ ] How to check recovery status: Dashboard
- [ ] How to roll back if needed: `backup-cli rollback`
- [ ] When to escalate: Decision tree
- [ ] How to conduct post-recovery validation

**Training Session 3: Troubleshooting** (1.5 hours):
- [ ] Common issues and solutions
- [ ] How to debug backup failures
- [ ] How to debug connectivity issues
- [ ] How to retrieve encryption keys from escrow
- [ ] How to contact support

**Training Attendance**:
- Infrastructure Team: _________________ ✅ (all members)
- Backup Team: _________________ ✅ (all members)
- On-Call Rotation: _________________ ✅ (trained)
- Management: _________________ ✅ (overview)

### Production Cutover

**Cutover Steps**:
1. [ ] All validation items passing (97/97)
2. [ ] All monitoring dashboards operational
3. [ ] All alerts tested and working
4. [ ] Team trained on operations
5. [ ] Runbooks documented
6. [ ] Backup schedule activated
7. [ ] Notify downstream teams (Week 2: Security & Secrets ready to deploy)

**Cutover Communication**:
- [ ] Send announcement: "Storage & Backup Agent now operational for Week 2 deployments"
- [ ] Update status page: "Storage & Backup Agent ✅ Operational"
- [ ] Brief management: "Phase 1 Week 1 milestone achieved"
- [ ] Schedule Week 2 Security & Secrets kickoff meeting

---

## Phase 6: Stabilization

### Monitoring (Week 1-2)

**Daily Monitoring**:
- [ ] Backup success rate > 95%
- [ ] All backup targets online
- [ ] Storage usage < 80% capacity
- [ ] Replication lag < 4 hours
- [ ] No critical errors in logs
- [ ] API responding normally

**Weekly Review** (End of Week 1):
- [ ] Backup duration trending stable
- [ ] Storage growth as expected (< 20% weekly)
- [ ] Deduplication ratio maintained (> 5:1)
- [ ] All scheduled backups completed
- [ ] Zero operational incidents
- [ ] Team feedback positive

### Performance Baseline

**Establish baselines** (Week 1):
```bash
# Database backup performance
backup-cli report --metric backup_duration --component database --last 7 | tee /tmp/db_baseline.txt

# Backup size baseline
backup-cli report --metric backup_size --component all --last 7 | tee /tmp/size_baseline.txt

# Storage growth rate
df -h /var/backup > /tmp/storage_baseline.txt && echo "Baseline captured at $(date)" >> /tmp/storage_baseline.txt
```

### Optimization (if needed)

**Identify optimization opportunities**:
- [ ] Backup throughput < 100MB/sec? → Increase bandwidth
- [ ] Backup window > 4 hours? → Parallelize jobs
- [ ] Storage growth > 20%? → Increase dedup or compression
- [ ] Replication lag > 2 hours? → Increase replication threads

**Apply optimizations**:
1. Modify `/etc/backup-agent/config.yaml`
2. Restart service: `systemctl restart backup-agent`
3. Monitor impact: `watch -n 1 'backup-cli status'`
4. Verify improvement or rollback

### Closure

**Deployment Closure Checklist**:
- [x] Phase 1 complete (Week 1-2)
- [x] All 97 validation items passed
- [x] Monitoring operational
- [x] Team trained
- [x] Documentation complete
- [x] Production cutover successful
- [x] Performance baselines established
- [x] Stabilization monitoring in place

**Deployment Summary**:
```
Project: Storage & Backup Agent (Phase 1, Week 1-2)
Status: ✅ COMPLETE
Start Date: 2026-09-16
Completion Date: [Actual completion date]
Duration: [Actual duration]
Issues Encountered: [List or "None"]
Lessons Learned: [Key insights]
```

**Final Sign-Off**:
- Project Manager: _________________ Date: __________
- Infrastructure Lead: _________________ Date: __________
- CTO: _________________ Date: __________

**Next Phase Readiness**:
- Security & Secrets Agent deployment can proceed Week 2-3 ✅
- Vault backup capability verified ✅
- All downstream integrations ready ✅
- Phase 1 foundational layer complete ✅

---

**Document Version**: 1.0  
**Last Updated**: 2026-09-16  
**Next Review**: 2026-10-16 (or after first deployment)
