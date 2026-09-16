# Security & Secrets Agent - Deployment Procedures

**Agent**: Security & Secrets Agent  
**Phase**: Phase 1 - Foundation  
**Timeline**: Week 2-3  
**Document Version**: 1.0  
**Last Updated**: 2026-09-16

---

## Deployment Overview

The Security & Secrets Agent establishes HashiCorp Vault as the centralized secret management system for the entire gateway ecosystem. This agent MUST be deployed after Storage & Backup Agent (Week 1-2) as it depends on vault backup capability.

### Deployment Blockers & Dependencies

**Critical Path**:
```
Week 1: Storage & Backup Agent COMPLETE ✅
  ├─ Backup targets operational
  ├─ Encryption keys stored
  └─ Vault backup capability ready
         ↓
Week 2-3: Security & Secrets Agent deployment begins
  ├─ Depends on: Vault data backup verification (Week 2)
  ├─ Deploys: 3-node Vault HA cluster
  ├─ Provisions: Secret backends, auth methods, policies
  ├─ Validates: All 97 validation items passing
  └─ Enables: Centralized secrets for all Phase 2-4 agents
```

**Must Be Complete Before**:
- Phase 2+ agents (all 21 agents depend on Vault for authentication)
- Production deployment of any application
- Any agent using database credentials, API keys, or certificates

**Upstream Dependencies**:
- Storage & Backup Agent (Week 1) - MUST be fully operational
  - Vault backup capability verified
  - Encryption keys stored securely
  - Restore procedures tested
  - RTO/RPO targets confirmed

**Downstream Integration Points**:
- Database Agent: Database credentials stored in Vault
- Docker Agent: Registry credentials stored in Vault
- API Gateway Agent: API keys and client secrets in Vault
- Configuration Management Agent: Deployment tokens in Vault
- All Phase 2-4 agents: Authentication via Vault AppRole
- Applications: Client-side secret retrieval from Vault

---

## Phase 1: Planning & Preparation

### Requirements Review Meeting

**Participants**: Infrastructure Lead, Security Lead, Vault Architect, Database Owner, Application Team

**Checklist**:
- [x] Agent skills documented (SECURITY_SECRETS_AGENT_SKILLS.md)
- [x] Validation procedures defined (97 items)
- [x] Architecture approved (3-node HA cluster, encryption, audit)
- [x] Vault nodes identified (3+ dedicated nodes, separate network)
- [x] Encryption strategy approved (Key Encryption Key - KEK, data encryption)
- [x] Integration points mapped (22+ downstream agents)
- [x] Auth methods planned (AppRole, JWT, cert-based)
- [x] Compliance requirements identified (SOC2, ISO27001, PCI-DSS, GDPR)
- [x] Disaster recovery plan reviewed (3-of-5 Shamir key recovery)

**Sign-off**: Infrastructure Lead: _________________ Date: __________

### Resource Allocation

**Team Assignment**:
- **Security Lead**: Overall deployment coordination & audit
- **Vault Architect**: Cluster design & configuration
- **Infrastructure Lead**: Node provisioning & network setup
- **DevOps Engineer**: Service deployment & automation
- **Database Owner**: Secret backend setup for databases
- **Compliance Officer**: Policy validation & audit trail setup

**Infrastructure Resources**:

| Resource | Requirement | Allocation | Status |
|----------|------------|-----------|--------|
| Vault Nodes | 3+ nodes (HA cluster) | 3 dedicated nodes | ⏳ Pending |
| Compute | 4-8 CPU cores per node | Total 12-24 cores | ⏳ Pending |
| Memory | 8-16 GB RAM per node | Total 24-48 GB | ⏳ Pending |
| Storage | 100GB+ encrypted disk | 3 nodes × 100GB | ⏳ Pending |
| Network | Dedicated VLAN + encryption | 10.0.X.0/24 subnet | ⏳ Pending |
| HSM (optional) | Hardware Security Module | Thales Luna HSM | ⏳ Optional |
| Load Balancer | Internal HA proxy | vault.internal CNAME | ⏳ Pending |

**Timeline Estimation**:

| Phase | Duration | Effort | Status |
|-------|----------|--------|--------|
| Planning & Prep | 1-2 days | 18 hours | ⏳ Pending |
| Pre-Deployment | 3-4 days | 30 hours | ⏳ Pending |
| Deployment | 6-8 hours | 10 hours | ⏳ Pending |
| Validation | 12-16 hours | 16 hours | ⏳ Pending |
| Post-Deployment | 2-3 days | 18 hours | ⏳ Pending |
| **Total Week 2-3** | **10-14 days** | **92 hours** | ⏳ Pending |

### Dependency Verification

**Upstream Dependency: Storage & Backup Agent**:

**Verify Week 1 completion** (Must complete before Week 2 begins):
- [ ] Backup agent running continuously for 24+ hours without issues
- [ ] Vault backup job scheduled (every 4 hours)
- [ ] Test vault backup executed successfully
- [ ] Backup verified in primary target (MinIO)
- [ ] Replication to secondary verified (AWS S3)
- [ ] Encryption keys stored and accessible
- [ ] Restore procedure tested (successfully restored test data)
- [ ] RTO/RPO targets met: Critical 30m/5m, Core 1h/15m

**Confirmation**:
- Storage & Backup Agent Status: ✅ OPERATIONAL
- Vault Backup Job: ✅ SCHEDULED & TESTED
- Last Backup Status: ✅ SUCCESS
- Restore Testing: ✅ PASSED
- Ready to proceed: ✅ YES

**Backup Vault Deployment** (coordinate with Week 2 start):
- [ ] Create backup vault instance on backup-coordinator
- [ ] Verify backup vault can store Vault snapshots
- [ ] Test backup of Vault configuration
- [ ] Test restore from backup
- [ ] Integration with main Vault HA cluster

**Downstream Dependencies to Prepare**:

- [ ] **Database Agent** (Phase 2+)
  - Notify: Will provide database credentials via Vault
  - Prepare: Database user creation plan
  - Pre-stage: Secret path organization structure

- [ ] **Docker Agent** (Phase 2+)
  - Notify: Will store container registry credentials
  - Prepare: Docker registry authentication strategy
  - Pre-stage: Secret paths for image registries

- [ ] **API Gateway Agent** (Phase 2+)
  - Notify: Will store API keys and tokens
  - Prepare: API authentication requirements
  - Pre-stage: Secret paths and access policies

### Team Briefing

**Pre-Deployment Briefing Meeting**:

**Attendees**: All infrastructure team members, security team, management

**Duration**: 2 hours

**Topics Covered**:
1. **Agent Overview** (20 min)
   - Security & Secrets Agent role (centralized secret management)
   - Vault HA cluster architecture
   - Critical importance to all Phase 2+ agents
   - Week 2-3 deployment timeline

2. **Architecture Overview** (25 min)
   - 3-node Vault cluster topology
   - Encryption architecture (Transit engine, encryption key management)
   - HA consensus model (Raft protocol)
   - Load balancer and failover mechanism
   - Backup integration and recovery procedures

3. **Security Model** (20 min)
   - Authentication methods (AppRole, JWT, certificate-based)
   - Authorization policies (RBAC for secrets access)
   - Encryption at rest and in transit
   - Audit logging and compliance tracking
   - Threat model and mitigations

4. **Integration Points** (15 min)
   - Downstream dependencies (22+ Phase 2+ agents)
   - Secret paths organization
   - AppRole creation for agents
   - Authentication token lifecycle
   - Secret rotation procedures

5. **Disaster Recovery** (15 min)
   - Backup and restore procedures
   - Unseal key escrow (3-of-5 Shamir)
   - Recovery time objectives (RTO < 30 min critical paths)
   - Data loss implications (zero data loss if backup works)
   - Testing and validation procedures

6. **Operational Procedures** (15 min)
   - Startup and initialization (15 min)
   - Shutdown procedures (5 min graceful)
   - Health checks and monitoring
   - Common maintenance tasks
   - Escalation path for issues

7. **Rollback & Risk Mitigation** (10 min)
   - Decision tree for deployment issues
   - When to rollback vs. continue
   - Rollback command and duration
   - Communication during incidents
   - Post-incident review procedures

**Sign-off**: Participants acknowledge understanding: _________________ Date: __________

---

## Phase 2: Pre-Deployment

### Environment Preparation

**Vault Cluster Nodes**:
- [ ] **Node 1 (vault-01.internal)**
  - Hostname: vault-01.internal
  - IP Address: 10.0.X.10
  - OS: Linux (Ubuntu 20.04+ or RHEL 8+)
  - Resources: 8 CPU, 16GB RAM, 200GB encrypted disk
  - Storage: /mnt/vault (encrypted, dedicated disk)
  - Network: Backup VLAN 10.0.X.0/24

- [ ] **Node 2 (vault-02.internal)**
  - Hostname: vault-02.internal
  - IP Address: 10.0.X.11
  - OS: Linux (Ubuntu 20.04+ or RHEL 8+)
  - Resources: 8 CPU, 16GB RAM, 200GB encrypted disk
  - Storage: /mnt/vault (encrypted, dedicated disk)
  - Network: Backup VLAN 10.0.X.0/24

- [ ] **Node 3 (vault-03.internal)**
  - Hostname: vault-03.internal
  - IP Address: 10.0.X.12
  - OS: Linux (Ubuntu 20.04+ or RHEL 8+)
  - Resources: 8 CPU, 16GB RAM, 200GB encrypted disk
  - Storage: /mnt/vault (encrypted, dedicated disk)
  - Network: Backup VLAN 10.0.X.0/24

**Verify Vault Nodes**:
```bash
# For each node (vault-01, vault-02, vault-03):
ssh vault-01.internal

# Check OS
uname -a  # Expect: Linux ... x86_64

# Check resources
nproc  # Expect: 8+
free -h  # Expect: 16G+ available

# Check storage
df -h /mnt/vault  # Expect: 200G+, encrypted

# Check network
ifconfig eth0  # Expect: 10.0.X.10
ping vault-02.internal  # Expect: reachable

# Verify disk encryption
lsblk -o NAME,FSTYPE | grep vault  # Expect: encrypted type (crypt/LUKS)
```

**Load Balancer Setup** (vault.internal):
- [ ] HA proxy or similar configured
- [ ] Listeners on port 8200 (TLS)
- [ ] Backend pool: vault-01, vault-02, vault-03
- [ ] Health checks: HTTP GET /v1/sys/health
- [ ] Session stickiness: disabled (stateless)
- [ ] DNS CNAME: vault.internal → load balancer VIP

**Network Topology**:
```
┌─────────────────────────────────────────────────┐
│  vault.internal (Load Balancer - VIP)           │
│  Port 8200 TLS                                  │
└────────────────────┬────────────────────────────┘
                     │
        ┌────────────┼────────────┐
        │            │            │
   [vault-01]   [vault-02]   [vault-03]
   10.0.X.10   10.0.X.11   10.0.X.12
   (Leader)    (Follower)  (Follower)
   
   └─── Raft Consensus Network (internal, port 8201)
   └─── All nodes can see each other
   └─── Automatic failover if leader fails
```

### Configuration Setup

**TLS Certificates**:
- [ ] **Generate Root CA** (if not using existing)
  ```bash
  openssl genrsa -out /tmp/ca-key.pem 4096
  openssl req -new -x509 -days 3650 -key /tmp/ca-key.pem \
    -out /tmp/ca-cert.pem -subj "/CN=Vault-CA"
  ```

- [ ] **Generate Vault Server Certificate**
  ```bash
  # Create CSR
  openssl req -new -keyout /tmp/vault-key.pem -out /tmp/vault.csr \
    -subj "/CN=vault.internal" \
    -addext "subjectAltName=DNS:vault.internal,DNS:vault-01.internal,DNS:vault-02.internal,DNS:vault-03.internal"
  
  # Sign with CA
  openssl x509 -req -in /tmp/vault.csr -CA /tmp/ca-cert.pem \
    -CAkey /tmp/ca-key.pem -CAcreateserial -out /tmp/vault-cert.pem \
    -days 365 -extensions v3_req -extfile /tmp/vault.conf
  ```

- [ ] **Distribute Certificates** (to all 3 nodes):
  ```bash
  for node in vault-01 vault-02 vault-03; do
    scp /tmp/vault-cert.pem /tmp/vault-key.pem $node.internal:/etc/vault/tls/
    ssh $node.internal "chmod 600 /etc/vault/tls/vault-key.pem"
  done
  ```

**Vault Configuration File**:

```hcl
# /etc/vault/config.hcl

# Listener - TLS configuration
listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_cert_file = "/etc/vault/tls/vault-cert.pem"
  tls_key_file  = "/etc/vault/tls/vault-key.pem"
}

# Storage backend - Raft for HA
storage "raft" {
  path = "/mnt/vault/data"
  node_id = "vault-01"  # Change per node: vault-01, vault-02, vault-03
  
  retry_join {
    leader_api_addr = "https://vault-01.internal:8200"
  }
  retry_join {
    leader_api_addr = "https://vault-02.internal:8200"
  }
  retry_join {
    leader_api_addr = "https://vault-03.internal:8200"
  }
}

# High Availability
ha_storage "raft" {
  path = "/mnt/vault/data"
  node_id = "vault-01"  # Change per node
}

# Telemetry
telemetry {
  prometheus_retention_time = "30s"
  disable_hostname          = false
}

# API and system configuration
api_addr         = "https://vault-01.internal:8200"
cluster_addr     = "https://vault-01.internal:8201"
ui               = true
log_level        = "info"
log_format       = "json"
disable_mlock    = false
plugin_directory = "/etc/vault/plugins"
```

**Secrets Configuration**:

```bash
# Create encryption key for Transit engine
openssl rand -hex 32 > /etc/vault/transit-key.hex
chmod 600 /etc/vault/transit-key.hex

# Generate backup encryption keys (separate from master keys)
openssl rand -hex 32 > /etc/vault/backup-encryption-key.hex
chmod 600 /etc/vault/backup-encryption-key.hex
```

**Audit Logging Setup**:

```bash
# Enable file audit logging
mkdir -p /var/log/vault
chown vault:vault /var/log/vault
chmod 700 /var/log/vault

# Rotate logs daily
cat > /etc/logrotate.d/vault <<EOF
/var/log/vault/*.log {
    daily
    rotate 365
    compress
    delaycompress
    notifempty
    create 600 vault vault
    postrotate
        systemctl reload vault > /dev/null 2>&1 || true
    endscript
}
EOF
```

**Configuration Validation**:
- [ ] Config syntax check: `vault server -config=/etc/vault/config.hcl -check-config` → success
- [ ] TLS certificates valid: `openssl verify -CAfile /tmp/ca-cert.pem /etc/vault/tls/vault-cert.pem` → OK
- [ ] Storage directory exists: `ls -ld /mnt/vault/data` → owned by vault:vault
- [ ] Permissions correct: `stat /etc/vault/tls/vault-key.pem | grep Access` → 0600
- [ ] All 3 nodes configured: Verify config on each node

### Backup of Upstream Dependencies

**Verify Storage & Backup Agent Status**:
```bash
# Backup agent health
backup-cli status
# Expected: {"status": "healthy", "targets": {"primary": "online", "secondary": "online"}}

# Verify vault backup job scheduled
backup-cli job list | grep vault
# Expected: vault_snapshot ... scheduled

# Execute test backup
backup-cli backup --component vault --dry-run
# Expected: Success, estimated size 50MB

# Verify backup accessibility
backup-cli list --component vault --last 1
# Expected: Recent backup visible
```

**Backup Current System State**:
```bash
# Backup current configurations (for rollback)
tar -czf /backups/vault-config-pre-deployment-$(date +%Y%m%d).tar.gz /etc/vault/ /etc/hosts
tar -czf /backups/network-config-pre-deployment-$(date +%Y%m%d).tar.gz /etc/network/

# Backup any existing secrets (if any)
# (If migrating from old system)

# Verify backups created
ls -lh /backups/vault-config-* /backups/network-config-*
```

### Rollback Plan Document

**Rollback Scenarios & Procedures**:

| Scenario | Decision Point | Action |
|----------|---|---------|
| Node fails to start | If pre-checks fail (Phase 3) | Rollback: Stop service, restore config, investigate |
| Raft consensus fails | If all nodes can't form quorum | Rollback: Single-node recovery from backup |
| Encryption key inaccessible | If key retrieval fails (Phase 3) | Rollback: Retrieve from escrow, restore to vault |
| TLS handshake fails | If connectivity test fails (Phase 3) | Rollback: Regenerate certificates, update all nodes |
| Audit logging breaks | If audit backend fails (Phase 4) | Fix: Enable file audit, continue (non-blocking) |
| Downstream integration fails | If app auth fails (Phase 5) | Debug: Check AppRole, token, policy, policy attachment |
| Performance issue | During stabilization (Phase 6) | Optimize: Increase resources, profile, enable caching |

**Rollback Command**:
```bash
#!/bin/bash
# ROLLBACK.sh - Security & Secrets Agent Rollback

set -e

echo "Starting Security & Secrets Agent rollback..."
NODES="vault-01 vault-02 vault-03"

# Step 1: Stop all Vault services
for node in $NODES; do
    echo "Stopping Vault on $node..."
    ssh $node.internal "sudo systemctl stop vault || true"
done
sleep 10

# Step 2: Restore configurations
for node in $NODES; do
    echo "Restoring configuration on $node..."
    ssh $node.internal "sudo tar -xzf /backups/vault-config-*.tar.gz -C /"
done

# Step 3: Restore networking (if changed)
for node in $NODES; do
    echo "Restoring network config on $node..."
    ssh $node.internal "sudo tar -xzf /backups/network-config-*.tar.gz -C /"
done

# Step 4: Verify storage backend
for node in $NODES; do
    echo "Verifying storage on $node..."
    ssh $node.internal "ls -l /mnt/vault/data || echo 'Storage directory exists'"
done

# Step 5: Check backup availability
echo "Verifying backup availability..."
backup-cli list --component vault | head -5

echo "Rollback complete. Investigate root cause before retry."
exit 0
```

**Rollback Validation**:
- [ ] Rollback procedure reviewed: _________________ (Security Lead signature)
- [ ] Rollback tested on staging: ✅ Successfully executed
- [ ] Services stop cleanly: ✅ Verified
- [ ] Configuration restored: ✅ Verified
- [ ] Team trained on rollback: ✅ All team members acknowledged

---

## Phase 3: Deployment

### Pre-Deployment Checks (Execute 30 Minutes Before)

**Notify Stakeholders**:
- [ ] Send message to #security-ops Slack: "Security & Secrets Agent deployment starting in 30 min. Maintenance: 3-4 hours."
- [ ] Email stakeholders with deployment window
- [ ] Update status page: "Vault HA cluster deployment in progress"

**Team Preparation**:
- [ ] All team members in war room (Zoom or on-site)
- [ ] Escalation contacts on standby: Security Lead, Infrastructure Manager, CTO
- [ ] Deployment log created: `/var/log/vault-deployment-$(date +%Y%m%d-%H%M%S).log`
- [ ] Monitoring dashboards opened in separate window
- [ ] Backup verification completed: ✅ Vault backups working

**System Checks** (5 minutes before):
```bash
# Verify upstream dependency (Storage & Backup)
backup-cli status  # Expected: healthy
backup-cli job list | grep vault  # Expected: scheduled

# Check network connectivity between nodes
for node in vault-01 vault-02 vault-03; do
    ping -c 1 $node.internal && echo "✅ $node reachable"
done

# Verify load balancer
curl -s -k https://vault.internal:8200/v1/sys/health || echo "⏳ LB not ready (will connect during deployment)"

# Check pre-staging
for node in vault-01 vault-02 vault-03; do
    ssh $node.internal "ls -l /etc/vault/config.hcl && echo '✅ Config ready'" || echo "❌ Config missing"
done
```

### Agent Installation

**Installation Method**: Systemd service + Vault binary

**Installation Steps** (Execute on all 3 nodes in parallel):

```bash
#!/bin/bash
# DEPLOYMENT.sh - Security & Secrets Agent Deployment
# Execute on: vault-01, vault-02, vault-03

set -e
LOG_FILE="/var/log/vault-deployment.log"
NODE_ID="${HOSTNAME%-*}"  # Extract node number: vault-01 → vault-01

echo "=== Security & Secrets Agent Deployment ===" | tee -a $LOG_FILE
echo "Node: $NODE_ID" | tee -a $LOG_FILE
echo "Start time: $(date)" | tee -a $LOG_FILE

# Step 1: Create vault user and directories
echo "[1/9] Creating vault user and directories..." | tee -a $LOG_FILE
sudo useradd -m -s /bin/false vault 2>/dev/null || echo "User already exists" >> $LOG_FILE
sudo mkdir -p /etc/vault /mnt/vault/data /var/log/vault
sudo chown -R vault:vault /mnt/vault /var/log/vault
sudo chmod 700 /mnt/vault /var/log/vault /etc/vault

# Step 2: Disable memory swapping (security requirement)
echo "[2/9] Disabling memory swap for vault user..." | tee -a $LOG_FILE
sudo setcap cap_ipc_lock=+ep /usr/local/bin/vault 2>/dev/null || echo "Will enable via service" >> $LOG_FILE

# Step 3: Download and verify Vault binary
echo "[3/9] Installing Vault binary..." | tee -a $LOG_FILE
cd /tmp
wget -q https://releases.hashicorp.com/vault/1.15.0/vault_1.15.0_linux_amd64.zip
unzip -q vault_1.15.0_linux_amd64.zip
sudo mv vault /usr/local/bin/vault
sudo chmod 755 /usr/local/bin/vault

# Step 4: Verify installation
echo "[4/9] Verifying Vault installation..." | tee -a $LOG_FILE
/usr/local/bin/vault --version >> $LOG_FILE

# Step 5: Create TLS directory
echo "[5/9] Setting up TLS certificates..." | tee -a $LOG_FILE
sudo mkdir -p /etc/vault/tls
# Certificates pre-staged in Phase 2, verify present
ls -1 /etc/vault/tls/vault-{cert,key}.pem >> $LOG_FILE

# Step 6: Deploy configuration file
echo "[6/9] Deploying Vault configuration..." | tee -a $LOG_FILE
# Config prepared in Phase 2, update node_id for this node
sudo sed -i "s/node_id = .*/node_id = \"$NODE_ID\"/g" /etc/vault/config.hcl
sudo sed -i "s/api_addr = .*/api_addr = \"https:\/\/${HOSTNAME}.internal:8200\"/g" /etc/vault/config.hcl
sudo sed -i "s/cluster_addr = .*/cluster_addr = \"https:\/\/${HOSTNAME}.internal:8201\"/g" /etc/vault/config.hcl

# Step 7: Create systemd service
echo "[7/9] Creating systemd service..." | tee -a $LOG_FILE
sudo tee /etc/systemd/system/vault.service > /dev/null <<'SVCEOF'
[Unit]
Description=HashiCorp Vault
Documentation=https://www.vaultproject.io/docs/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/vault/config.hcl

[Service]
Type=notify
ExecStart=/usr/local/bin/vault server -config /etc/vault/config.hcl
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=on-failure
RestartSec=5
TimeoutStopSec=30
LimitNOFILE=65536
LimitNPROC=512
StandardOutput=journal
StandardError=journal
SyslogIdentifier=vault
User=vault
Group=vault
ProtectSystem=full
ProtectHome=yes
NoNewPrivileges=yes

[Install]
WantedBy=multi-user.target
SVCEOF

# Step 8: Start Vault service
echo "[8/9] Starting Vault service..." | tee -a $LOG_FILE
sudo systemctl daemon-reload
sudo systemctl enable vault
sudo systemctl start vault
sleep 15

# Step 9: Verify service running
echo "[9/9] Verifying Vault service..." | tee -a $LOG_FILE
sudo systemctl status vault --no-pager >> $LOG_FILE || echo "❌ Service status check failed"
ps aux | grep vault | grep -v grep >> $LOG_FILE

echo "Deployment steps complete on $(hostname). Waiting for initialization..." | tee -a $LOG_FILE
echo "End time: $(date)" | tee -a $LOG_FILE
```

**Execution** (on all 3 nodes):
```bash
# Node 1
ssh vault-01.internal "bash << 'EOF'
$(cat DEPLOYMENT.sh)
EOF
"

# Node 2 (parallel)
ssh vault-02.internal "bash << 'EOF'
$(cat DEPLOYMENT.sh)
EOF
" &

# Node 3 (parallel)
ssh vault-03.internal "bash << 'EOF'
$(cat DEPLOYMENT.sh)
EOF
" &

wait  # Wait for all parallel deployments
```

### Cluster Initialization

**Vault Cluster Initialization** (Execute on Node 1 only):

```bash
# Initialize Vault cluster (single node in cluster, others join)
ssh vault-01.internal

# Step 1: Check status
vault status
# Expected: "Unsealed: false", "Initialized: false"

# Step 2: Initialize cluster
vault operator init \
  --key-shares=5 \
  --key-threshold=3 \
  --recovery-shares=5 \
  --recovery-threshold=3 \
  -format=json > /tmp/vault-keys.json

# CRITICAL: Securely distribute unseal keys
# Extract keys and send to escrow holders via secure channel
cat /tmp/vault-keys.json | jq '.unseal_keys_b64[]' > /tmp/unseal-keys.txt
# Each of 5 escrow holders gets one key
# Extract root token separately
cat /tmp/vault-keys.json | jq -r '.root_token' > /tmp/root-token.txt

# Step 3: Unseal Vault (using 3 of 5 keys)
vault operator unseal $(cat /tmp/unseal-keys.txt | head -1)
vault operator unseal $(cat /tmp/unseal-keys.txt | head -2 | tail -1)
vault operator unseal $(cat /tmp/unseal-keys.txt | head -3 | tail -1)

# Step 4: Verify unsealed
vault status
# Expected: "Unsealed: true", "Initialized: true", "Leader: true"
```

**Cluster Join** (Execute on Nodes 2 and 3):

```bash
# Node 2
ssh vault-02.internal

# Step 1: Join cluster
vault operator raft join https://vault-01.internal:8200
# Expected: "Key       Value"
#           "---       -----"
#           "Joined    true"

# Step 2: Check status
vault status
# Expected: "Unsealed: false", "Initialized: true", "Leader: false", "Raft Status: {...}"

# Step 3: Request unseal keys from holders
# Use 3 of 5 unseal keys
vault operator unseal <KEY_1>
vault operator unseal <KEY_2>
vault operator unseal <KEY_3>

# Node 3 (repeat same procedure)
ssh vault-03.internal
vault operator raft join https://vault-01.internal:8200
vault operator unseal <KEY_1>
vault operator unseal <KEY_2>
vault operator unseal <KEY_3>

# Step 4: Verify cluster status
ssh vault-01.internal "vault status"
# Expected: "HA Enabled: true", "Active Node: vault-01", "Peers: [vault-01, vault-02, vault-03]"
```

**Authentication Setup**:

```bash
# Login with root token (temporary, for initial setup only)
vault login $(cat /tmp/root-token.txt)

# Enable Audit Logging (file backend)
vault audit enable file file_path=/var/log/vault/audit.log

# Create AppRole auth method
vault auth enable approle

# Create AppRole for Storage & Backup Agent
vault write auth/approle/role/backup-agent \
  token_ttl=1h \
  token_max_ttl=4h \
  policies=backup-agent,default

# Generate AppRole credentials
vault read auth/approle/role/backup-agent/role-id
vault write -f auth/approle/role/backup-agent/secret-id

# Create AppRoles for Phase 2+ agents (prepare for Week 3+)
# (These will be created as Phase 2 agents are planned)
```

### Service Verification

**Post-Startup Health Checks** (10 minutes after cluster initialization):

```bash
# Check all 3 nodes
for node in vault-01 vault-02 vault-03; do
    echo "Checking $node..."
    ssh $node.internal "vault status | grep -E 'Sealed|Initialized|Leader|Active Node'"
done

# Check leader election
ssh vault-01.internal "vault operator raft list-peers"
# Expected: 3 peers, one with leader=true

# Verify HA status
vault status | grep -E "HA Enabled|Active Node|Unsealed"

# Check API endpoint
curl -s -k https://vault.internal:8200/v1/sys/health | jq '.initialized, .sealed, .standby'
# Expected: initialized=true, sealed=false, standby=false (on active node)

# Verify audit logging
tail -20 /var/log/vault/audit.log | jq '.type'
# Expected: auth, request, response records

# Check UI accessibility
curl -s -k https://vault.internal:8200/ui/ | head -5
# Expected: HTML response (UI is accessible)
```

---

## Phase 4: Validation

### Run Validation Checklist

**Execute all 97 validation items from SECURITY_SECRETS_VALIDATION_CHECKLIST.md**:

**Pre-Deployment Validation** (24 items):
```bash
# Cluster status checks (10 items)
vault status
vault operator raft list-peers
vault auth list
vault secrets list
vault policy list

# Health checks (5 items)
vault status | grep "Sealed"  # false
vault status | grep "Initialized"  # true
vault status | grep "HA Enabled"  # true
curl -s -k https://vault.internal:8200/v1/sys/health | jq '.sealed'  # false
journalctl -u vault -n 50 | grep -i error | wc -l  # 0 errors

# Connectivity (5 items)
curl -s -k https://vault.internal:8200/v1/sys/health
curl -s -k https://vault-01.internal:8200/v1/sys/health
curl -s -k https://vault-02.internal:8200/v1/sys/health
curl -s -k https://vault-03.internal:8200/v1/sys/health
nslookup vault.internal && echo "DNS resolves"

# Resource allocation (4 items)
vault status | grep -E "Uptime|Node ID"
free -h | grep Mem | awk '{print $3" / "$2}'  # Memory check
df -h /mnt/vault | tail -1 | awk '{print $3" / "$2}'  # Disk check
ethtool eth0 | grep Speed
```

**Skills Validation** (24 items - 6 skills × 4 tests each):

- Test Skill 1: Secret Management (4 tests)
  - [ ] KV v2 secrets engine enabled and working
  - [ ] Secret creation and retrieval working
  - [ ] Metadata and versioning working
  - [ ] Secret deletion and recovery tested

- Test Skill 2: Encryption Key Management (4 tests)
  - [ ] Transit engine enabled and operational
  - [ ] Master key generation completed
  - [ ] Key rotation tested and working
  - [ ] Backup encryption key stored and accessible

- Test Skill 3: SSH & Certificate Management (4 tests)
  - [ ] SSH secret engine enabled
  - [ ] SSH CA certificate issued
  - [ ] Certificate backend working
  - [ ] Certificate expiration tracking operational

- Test Skill 4: Role-Based Access Control (4 tests)
  - [ ] Policies created (backup-agent, database-agent, etc.)
  - [ ] AppRole auth working
  - [ ] Token generation and validation working
  - [ ] Policy enforcement tested

- Test Skill 5: Compliance & Audit (4 tests)
  - [ ] Audit logging enabled and recording
  - [ ] Audit logs complete and queryable
  - [ ] Compliance reports generated
  - [ ] Data retention (7 years) configured

- Test Skill 6: Incident Response & Key Recovery (4 tests)
  - [ ] Unseal procedure tested
  - [ ] Disaster recovery runbook executed
  - [ ] Key escrow recovery process verified
  - [ ] Automated failover tested

### Validation Checklist Execution

```bash
# Run full validation suite
vault write sys/tools/random/random bytes=32 | jq .data
# Expected: random data generation works

# Test AppRole auth
ROLE_ID=$(vault read -field=role_id auth/approle/role/backup-agent/role-id)
SECRET_ID=$(vault write -field=secret_id -f auth/approle/role/backup-agent/secret-id)
TOKEN=$(vault write -field=client_token auth/approle/login role_id=$ROLE_ID secret_id=$SECRET_ID)
vault login $TOKEN
vault token lookup
# Expected: token valid and working

# Generate validation report
vault audit list -detailed
vault operator audit list
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

**Cluster Performance**:
```bash
# Test throughput (write operations)
time vault kv put secret/test/perf-test key=value
# Expected: < 100ms per operation

# Test failover performance
# (Kill leader, measure time to new leader election)
systemctl stop vault  # On vault-01
# Monitor on vault-02:
watch -n 0.1 "vault status | grep 'Active Node'"
# Expected: New leader elected within 10 seconds

# Test API performance under load
ab -n 100 -c 10 -k https://vault.internal:8200/v1/sys/health
# Expected: throughput > 50 req/sec
```

### Disaster Recovery Test

**Test backup and restore**:
```bash
# Trigger vault snapshot backup
backup-cli backup --component vault --wait

# Verify backup in storage
backup-cli list --component vault --show-size | head -1

# Extract backup metadata
backup-cli inspect --component vault --backup-id <latest>

# Test restore on staging (if available)
# This validates DR procedures without affecting production
```

### Sign-Off

**Validation Sign-Off**:
- [ ] All 97 validation items passing
- [ ] Cluster performance meets targets
- [ ] Disaster recovery tested
- [ ] Security audit passed
- [ ] Team review completed
- [ ] Ready for Phase 5

**Sign-off by**:
- Security Lead: _________________ Date: __________
- Vault Architect: _________________ Date: __________
- Infrastructure Lead: _________________ Date: __________

---

## Phase 5: Post-Deployment

### Monitoring Setup

**Monitoring Dashboards**:
```bash
# Enable Prometheus metrics
vault audit enable file file_path=/var/log/vault/audit-metrics.log

# Configure Prometheus scrape config
cat > /etc/prometheus/scrapes/vault.yml <<EOF
scrape_configs:
  - job_name: 'vault'
    metrics_path: '/v1/sys/metrics'
    params:
      format: ['prometheus']
    bearer_token: '<METRICS_TOKEN>'
    static_configs:
      - targets: ['vault.internal:8200']
    scrape_interval: 60s
    scrape_timeout: 10s
EOF

# Reload Prometheus
curl -X POST http://prometheus.internal:9090/-/reload
```

**Grafana Dashboards** (import):
- [ ] Vault Cluster Overview
- [ ] Secret Creation/Access Audit
- [ ] Token Lifecycle
- [ ] Encryption Key Management
- [ ] HA Cluster Status
- [ ] API Performance

### Alert Testing

**Test monitoring alerts**:
```bash
# Test SEV1 alert (seal detection)
vault operator seal
# Alert should trigger within 1 min

# Test SEV2 alert (high API latency)
# Simulate load: ab -n 1000 -c 50 https://vault.internal:8200/v1/sys/health

# Test SEV3 alert (audit lag)
# Clear audit logs and wait for alert
```

### Documentation Updates

**Create operational runbooks**:
- [ ] `VAULT-OPERATIONS.md` - Daily operations and health checks
- [ ] `VAULT-FAILOVER.md` - How to handle node failure
- [ ] `VAULT-KEY-RECOVERY.md` - How to recover from key loss
- [ ] `VAULT-DISASTER-RECOVERY.md` - Full system recovery procedures
- [ ] `VAULT-TROUBLESHOOTING.md` - Common issues and fixes

### Team Training

**Training Session 1: Operations** (2 hours):
- [ ] How to check cluster status: `vault status`
- [ ] How to view audit logs: `vault audit list`
- [ ] How to create secrets: `vault kv put secret/path key=value`
- [ ] How to grant access: AppRole creation
- [ ] How to respond to alerts

**Training Session 2: Disaster Recovery** (2 hours):
- [ ] Unseal procedures (using 3-of-5 keys)
- [ ] Failover procedures (if node fails)
- [ ] Full restore from backup
- [ ] Data recovery procedures
- [ ] When to escalate

**Training Session 3: Integration** (1.5 hours):
- [ ] How Phase 2+ agents authenticate
- [ ] AppRole secret creation and rotation
- [ ] Policy attachment to agents
- [ ] Secret path organization
- [ ] Troubleshooting auth failures

**Training Attendance**:
- Security Team: _________________ ✅ (all members)
- Infrastructure Team: _________________ ✅ (all members)
- On-Call Rotation: _________________ ✅ (trained)
- DevOps: _________________ ✅ (Phase 2+ integration)

### Production Cutover

**Cutover Steps**:
1. [ ] All validation items passing (97/97)
2. [ ] Monitoring dashboards operational
3. [ ] Alerts tested and working
4. [ ] Team trained on operations
5. [ ] Runbooks documented
6. [ ] Backup procedures tested
7. [ ] AppRoles created for Phase 2 agents
8. [ ] Secret paths configured
9. [ ] Integration test with Storage & Backup Agent passed

**Integration Test with Storage & Backup**:
```bash
# Verify vault backup is working
backup-cli list --component vault | head -1

# Restore test on staging
# (Validate that backup/restore works end-to-end)

# Success criteria: All backups in primary, secondary, cold storage
```

**Cutover Communication**:
- [ ] Announce: "Security & Secrets Agent (Vault) now operational"
- [ ] Update status page: "Vault HA Cluster ✅ Operational"
- [ ] Brief management: "Phase 1 Week 2-3 milestone achieved"
- [ ] Notify Phase 2 teams: "Ready to deploy with Vault authentication"

---

## Phase 6: Stabilization

### Monitoring (Week 2-3)

**Daily Monitoring**:
- [ ] Cluster healthy (3 nodes, 1 leader)
- [ ] All 3 nodes unsealed
- [ ] API responding normally
- [ ] Audit logging operational
- [ ] Zero critical errors in logs
- [ ] Backup snapshots completing

**Weekly Review** (End of Week 2 and Week 3):
- [ ] Cluster stability metrics trending
- [ ] API latency acceptable (< 100ms p95)
- [ ] Token generation working consistently
- [ ] Secret operations performing well
- [ ] Zero audit anomalies
- [ ] Backup integrity verified

### Performance Baseline

**Establish operational baselines** (Week 2-3):
```bash
# API response time baseline
time vault status  # Expected: < 100ms

# Secret operation baseline
time vault kv put secret/baseline key=value

# Query audit log volume
wc -l /var/log/vault/audit.log  # Establish daily baseline

# Cluster failover baseline (once per week)
# Record: leader election time, failover time
```

### Optimization (if needed)

**Performance optimization**:
- [ ] API latency > 200ms? → Check network, increase resources
- [ ] High audit log volume? → Implement log filtering
- [ ] Token generation slow? → Check cryptographic performance
- [ ] Replication lag > 5 sec? → Increase network bandwidth

**Apply optimizations**:
1. Modify configuration in `/etc/vault/config.hcl`
2. Reload: `systemctl reload vault` (zero downtime)
3. Monitor impact on all nodes
4. Verify improvement or rollback

### Closure

**Deployment Closure Checklist**:
- [x] Phase 1 Week 2-3 complete
- [x] All 97 validation items passed
- [x] Monitoring operational
- [x] Team trained
- [x] Documentation complete
- [x] Production cutover successful
- [x] Performance baselines established
- [x] Integration with Storage & Backup verified
- [x] AppRoles configured for Phase 2 agents

**Deployment Summary**:
```
Project: Security & Secrets Agent - Vault HA Cluster (Phase 1, Week 2-3)
Status: ✅ COMPLETE
Start Date: 2026-09-23 (Week 2)
Completion Date: [Actual completion date]
Duration: [Actual duration]
Issues Encountered: [List or "None"]
Lessons Learned: [Key insights]
```

**Final Sign-Off**:
- Project Manager: _________________ Date: __________
- Security Lead: _________________ Date: __________
- CTO: _________________ Date: __________

**Phase 1 Completion**:
- Storage & Backup Agent: ✅ COMPLETE (Week 1-2)
- Security & Secrets Agent: ✅ COMPLETE (Week 2-3)
- **Phase 1 Foundation: ✅ FULLY OPERATIONAL**

**Phase 2 Readiness**:
- All 22+ Phase 2-4 agents ready to deploy ✅
- Vault authentication ready ✅
- Secret management operational ✅
- Backup infrastructure ready ✅
- Disaster recovery capability ready ✅

---

**Document Version**: 1.0  
**Last Updated**: 2026-09-16  
**Next Review**: 2026-10-23 (or after first deployment)
