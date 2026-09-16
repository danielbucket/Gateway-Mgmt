# Storage & Backup Agent - Validation Checklist

**Agent**: Storage & Backup Agent  
**Phase**: Phase 1 - Foundation  
**Timeline**: Weeks 1-2  
**Date Created**: 2026-09-16  
**Last Updated**: 2026-09-16

---

## Pre-Deployment Validation

### Installation & Configuration
- [ ] **Backup coordinator binary installed** - Verify `/usr/local/bin/backup-coordinator` exists and is executable
  - Command: `which backup-coordinator && file /usr/local/bin/backup-coordinator`
  - Success: Binary found and identified as ELF executable
  - Owner: Infrastructure Team

- [ ] **Backup configuration file present** - Verify `/etc/backup-agent/config.yaml` exists with required sections
  - Command: `cat /etc/backup-agent/config.yaml | head -20`
  - Success: File contains `backup_targets`, `retention_policies`, `encryption_key` sections
  - Owner: Infrastructure Team

- [ ] **Backup service systemd unit configured** - Verify service file exists and is valid
  - Command: `systemctl cat backup-agent | head -20`
  - Success: Service file valid with Type=simple, User=backup, ExecStart=/usr/local/bin/backup-coordinator
  - Owner: Infrastructure Team

- [ ] **Primary storage backend configured** - Verify S3/MinIO connection parameters
  - Command: `aws s3 ls --endpoint-url https://minio.internal:9000 backup-primary 2>&1 | head`
  - Success: Lists bucket contents without errors
  - Owner: Infrastructure Team

- [ ] **Secondary storage backend configured** - Verify off-site S3 credentials
  - Command: `aws s3 ls --endpoint-url https://aws.s3.amazonaws.com backup-secondary 2>&1 | head`
  - Success: Lists bucket contents without errors
  - Owner: Infrastructure Team

- [ ] **Encryption keys generated and stored** - Verify backup encryption master key exists
  - Command: `vault kv get secret/backup-agent/encryption-key 2>&1 | grep -i key_id`
  - Success: Key metadata displayed without errors
  - Owner: Security Team

- [ ] **Key escrow procedure documented** - Verify 5 shares generated and stored
  - Command: `ls -la /var/backup/escrow/ | wc -l`
  - Success: Shows 5 escrow share files
  - Owner: Security Team

- [ ] **Backup network isolation verified** - Verify dedicated VLAN for backup traffic
  - Command: `ip route show | grep backup-vlan`
  - Success: Backup VLAN route present
  - Owner: Network Team

### Health Checks
- [ ] **Backup coordinator process running** - Verify service is active
  - Command: `systemctl status backup-agent | grep Active`
  - Success: Shows "Active: active (running)"
  - Owner: Infrastructure Team

- [ ] **API endpoint responding** - Verify backup-agent API accessible
  - Command: `curl -s https://backup-agent.internal:5000/health | jq '.status'`
  - Success: JSON response with "status": "healthy"
  - Owner: Infrastructure Team

- [ ] **Audit logging enabled** - Verify audit logs being written
  - Command: `tail -5 /var/log/backup-agent/audit.log | grep -i backup`
  - Success: Recent backup operation logged
  - Owner: Infrastructure Team

- [ ] **Backup scheduler initialized** - Verify scheduler running and jobs loaded
  - Command: `backup-cli job list | head -5`
  - Success: Lists scheduled backup jobs
  - Owner: Infrastructure Team

- [ ] **No critical errors in startup logs** - Verify clean startup
  - Command: `journalctl -u backup-agent -n 20 | grep -i error`
  - Success: No ERROR or CRITICAL level messages
  - Owner: Infrastructure Team

### Connectivity
- [ ] **Primary storage endpoint reachable** - Test network connectivity to MinIO
  - Command: `telnet minio.internal 9000 < /dev/null`
  - Success: Connection successful (not refused/timeout)
  - Owner: Network Team

- [ ] **Primary storage credentials valid** - Test S3 authentication
  - Command: `aws s3api head-bucket --bucket backup-primary --endpoint-url https://minio.internal:9000 2>&1`
  - Success: Returns "204 No Content" or similar success status
  - Owner: Infrastructure Team

- [ ] **Secondary storage endpoint reachable** - Test off-site S3 connectivity
  - Command: `aws s3 ls backup-secondary --endpoint-url https://aws.s3.amazonaws.com 2>&1 | head`
  - Success: Bucket accessible without connection errors
  - Owner: Network Team

- [ ] **Cold storage endpoint reachable** - Test archive storage connectivity
  - Command: `aws s3 ls backup-cold --endpoint-url https://aws.s3.amazonaws.com 2>&1 | head`
  - Success: Bucket accessible without connection errors
  - Owner: Network Team

- [ ] **Backup agents can reach coordinator** - Verify network path from agent nodes
  - Command: `ssh backup-agent-01 "curl -s https://backup-coordinator.internal:5000/health" | jq '.status'`
  - Success: Returns health status from remote node
  - Owner: Network Team

- [ ] **Database server connectivity** - Test connection to backup source databases
  - Command: `mysql -u backup_user -p -h database.internal -e "SELECT 1" 2>&1`
  - Success: Command returns "1" without authentication errors
  - Owner: Database Team

- [ ] **Vault server connectivity** - Test connection to secrets vault
  - Command: `vault status -address=https://vault.internal:8200 2>&1 | grep "Sealed"`
  - Success: Vault status returned (Sealed or Unsealed)
  - Owner: Infrastructure Team

### Resource Allocation
- [ ] **CPU resources adequate** - Verify backup coordinator has 2-4 CPU cores
  - Command: `nproc && grep "siblings" /proc/cpuinfo | head -1`
  - Success: System has ≥4 cores, backup coordinator can use 2-4
  - Owner: Infrastructure Team

- [ ] **Memory resources adequate** - Verify 4-8GB RAM allocated
  - Command: `free -h | grep "^Mem"`
  - Success: Total memory ≥8GB, backup coordinator gets 4-8GB
  - Owner: Infrastructure Team

- [ ] **Disk space available** - Verify sufficient space for backup cache
  - Command: `df -h /var/backup | awk 'NR==2 {print $4}'`
  - Success: Available space ≥100GB
  - Owner: Infrastructure Team

- [ ] **Network bandwidth adequate** - Verify dedicated backup network
  - Command: `ethtool -s backup-eth0 2>&1 | grep Speed || echo "Speed detection failed"`
  - Success: Network interface speed ≥1Gbps
  - Owner: Network Team

---

## Skills Validation

### Skill 1: Backup Infrastructure Design & Setup

**Test 1a: Multi-target backup architecture**
- [ ] Primary backup target configured and accessible
  - Command: `backup-cli target list | grep -i primary`
  - Success: Primary target listed with status "online"
  - Owner: Infrastructure Team

- [ ] Secondary backup target configured and accessible
  - Command: `backup-cli target list | grep -i secondary`
  - Success: Secondary target listed with status "online"
  - Owner: Infrastructure Team

- [ ] Cold storage target configured and accessible
  - Command: `backup-cli target list | grep -i cold`
  - Success: Cold storage target listed with status "online"
  - Owner: Infrastructure Team

- [ ] Geographic distribution configured (targets in different regions)
  - Command: `backup-cli target list -v | grep -E "region|location"`
  - Success: Targets in different regions documented
  - Owner: Infrastructure Team

**Test 1b: Encryption key management**
- [ ] Backup encryption master key generated
  - Command: `vault kv get -field=key_id secret/backup-agent/encryption-key`
  - Success: Key ID returned without errors
  - Owner: Security Team

- [ ] Key stored separately from primary vault
  - Command: `vault auth list | grep -i backup`
  - Success: Backup service has separate authentication context
  - Owner: Security Team

- [ ] Key rotation schedule defined
  - Command: `cat /etc/backup-agent/config.yaml | grep -A2 "key_rotation"`
  - Success: Rotation schedule defined (e.g., "annually")
  - Owner: Security Team

**Test 1c: Retention policies defined**
- [ ] Hot tier retention (7 days) configured
  - Command: `backup-cli policy list | grep -A3 "hot"`
  - Success: Hot tier retention = 7 days
  - Owner: Infrastructure Team

- [ ] Warm tier retention (30 days) configured
  - Command: `backup-cli policy list | grep -A3 "warm"`
  - Success: Warm tier retention = 30 days
  - Owner: Infrastructure Team

- [ ] Cold tier retention (365+ days) configured
  - Command: `backup-cli policy list | grep -A3 "cold"`
  - Success: Cold tier retention ≥ 365 days
  - Owner: Infrastructure Team

- [ ] Compliance retention (7 years) configured
  - Command: `backup-cli policy list | grep -A3 "compliance"`
  - Success: Compliance tier retention = 2555+ days (7 years)
  - Owner: Compliance Team

---

### Skill 2: Automated Backup Orchestration

**Test 2a: Database backup scheduling**
- [ ] Full database backup scheduled weekly
  - Command: `backup-cli job list --component database | grep full`
  - Success: Full backup job scheduled (e.g., "every Sunday 1:00 AM UTC")
  - Owner: Database Team

- [ ] Incremental database backups scheduled daily
  - Command: `backup-cli job list --component database | grep incremental`
  - Success: Incremental job scheduled (e.g., "daily 2:00 AM UTC")
  - Owner: Database Team

- [ ] Transaction log backups scheduled every 15 minutes
  - Command: `backup-cli job list --component database | grep "transaction\|log"`
  - Success: Log backup scheduled every 15 minutes
  - Owner: Database Team

**Test 2b: Vault snapshot scheduling**
- [ ] Vault snapshots scheduled every 4 hours
  - Command: `backup-cli job list --component vault`
  - Success: Vault backup job scheduled every 4 hours
  - Owner: Infrastructure Team

- [ ] On-demand vault backup capability verified
  - Command: `backup-cli backup --component vault --dry-run`
  - Success: Dry-run succeeds, shows would backup current vault state
  - Owner: Infrastructure Team

**Test 2c: Configuration backup scheduling**
- [ ] Configuration backups scheduled every 6 hours
  - Command: `backup-cli job list --component config`
  - Success: Config backup scheduled every 6 hours
  - Owner: Infrastructure Team

- [ ] Trigger-based backups on deployment
  - Command: `grep -r "backup-trigger" /etc/deployment | head -3`
  - Success: Deployment hooks trigger backups
  - Owner: DevOps Team

**Test 2d: Backup dependency management**
- [ ] Backup scheduler using distributed lock (etcd/Consul)
  - Command: `etcdctl member list 2>&1 || consul members 2>&1 | grep -i member`
  - Success: Coordinator found in etcd/Consul
  - Owner: Infrastructure Team

- [ ] No duplicate backups executing simultaneously
  - Command: `backup-cli job log --last 100 | grep -i "skipped\|duplicate" | wc -l`
  - Success: No or minimal (< 2) duplicate jobs in last 100 runs
  - Owner: Infrastructure Team

- [ ] Backup pre-checks (connectivity, permissions) passing
  - Command: `backup-cli job log --last 1 --component database | grep "pre-check"`
  - Success: Pre-checks passed status visible in log
  - Owner: Infrastructure Team

**Test 2e: Failure handling and retry logic**
- [ ] Backup retries configured for failed jobs
  - Command: `cat /etc/backup-agent/config.yaml | grep -A3 "retry"`
  - Success: Retry configuration present (e.g., "max_retries: 3, backoff: exponential")
  - Owner: Infrastructure Team

- [ ] Timeout configured per component
  - Command: `cat /etc/backup-agent/config.yaml | grep -A5 "timeout"`
  - Success: Component-specific timeouts defined (DB 1h, Vault 30m, Config 10m)
  - Owner: Infrastructure Team

- [ ] Failure alerts triggered
  - Command: `backup-cli job log --last 100 --status failed | head -1 | grep -i alert`
  - Success: Alert triggered on failed backup
  - Owner: Infrastructure Team

---

### Skill 3: Backup Verification & Testing

**Test 3a: Backup integrity checks**
- [ ] Backup manifest generated for each backup
  - Command: `backup-cli list --limit 1 --show-manifest | head -20`
  - Success: Manifest displayed with file list and checksums
  - Owner: Infrastructure Team

- [ ] Manifest checksum verification passing
  - Command: `backup-cli verify --backup-id $(backup-cli list --limit 1 | awk '{print $1}') --manifest-only`
  - Success: Manifest verification passed
  - Owner: Infrastructure Team

- [ ] Encryption verification passing (backup encrypted with correct key)
  - Command: `backup-cli verify --backup-id $(backup-cli list --limit 1 | awk '{print $1}') --encryption-check`
  - Success: Encryption verified with correct master key
  - Owner: Security Team

**Test 3b: Monthly restore simulation**
- [ ] Monthly restore test executed (in past 30 days)
  - Command: `backup-cli test list --type restore-sim --days 30 | head -1`
  - Success: Restore simulation found in past 30 days
  - Owner: Infrastructure Team

- [ ] Restore simulation verified 100% of backup accessible
  - Command: `backup-cli test show --id $(backup-cli test list --type restore-sim --days 30 | head -1 | awk '{print $1}') | grep "result: success"`
  - Success: Test result shows "success"
  - Owner: Infrastructure Team

- [ ] Restore simulation documented with no critical issues
  - Command: `backup-cli test show --id $(backup-cli test list --type restore-sim --days 30 | head -1 | awk '{print $1}') | grep -i "critical" | wc -l`
  - Success: Zero critical issues found
  - Owner: Infrastructure Team

**Test 3c: Quarterly full restore test**
- [ ] Quarterly full restore test executed
  - Command: `backup-cli test list --type restore-full --days 90 | head -1`
  - Success: Full restore test found in past 90 days
  - Owner: Infrastructure Team

- [ ] Full restore test completed successfully
  - Command: `backup-cli test show --id $(backup-cli test list --type restore-full --days 90 | head -1 | awk '{print $1}') | grep "result: success"`
  - Success: Full restore succeeded
  - Owner: Infrastructure Team

- [ ] Test timing within RTO targets
  - Command: `backup-cli test show --id $(backup-cli test list --type restore-full --days 90 | head -1 | awk '{print $1}') | grep -i "duration"`
  - Success: Duration < RTO target (critical 30min, core 1h, standard 4h)
  - Owner: Infrastructure Team

- [ ] Test report signed by infrastructure lead
  - Command: `backup-cli test show --id $(backup-cli test list --type restore-full --days 90 | head -1 | awk '{print $1}') | grep -i "approved_by"`
  - Success: Report shows approval by authorized personnel
  - Owner: Infrastructure Team

**Test 3d: Backup discovery and inventory**
- [ ] Central backup catalog system operational
  - Command: `backup-cli catalog status`
  - Success: Catalog shows "operational" with backup count
  - Owner: Infrastructure Team

- [ ] Backups tagged with metadata (component, date, retention class)
  - Command: `backup-cli list --limit 1 --show-metadata | grep -E "component|date|retention"`
  - Success: Metadata tags displayed for backup
  - Owner: Infrastructure Team

- [ ] Backup chain lineage tracked (full + incremental dependencies)
  - Command: `backup-cli lineage show --backup-id $(backup-cli list --type incremental --limit 1 | awk '{print $1}')`
  - Success: Full backup parent shown for incremental
  - Owner: Infrastructure Team

**Test 3e: Compliance documentation**
- [ ] Backup verification reports generated
  - Command: `backup-cli report list --type verification --days 30 | head -1`
  - Success: Verification report found in past 30 days
  - Owner: Compliance Team

- [ ] Audit trail captured for restore operations
  - Command: `backup-cli audit log --component restore --days 30 | head -3`
  - Success: Restore operations logged with user/timestamp
  - Owner: Audit Team

- [ ] Compliance reports generated (SOC2, PCI-DSS)
  - Command: `backup-cli report list --type compliance | head -3`
  - Success: Multiple compliance reports available
  - Owner: Compliance Team

---

### Skill 4: Disaster Recovery Coordination

**Test 4a: Disaster recovery procedures documented**
- [ ] Recovery phase sequence defined and validated
  - Command: `cat /var/backup/runbooks/recovery-phases.md | grep -E "^## Phase"`
  - Success: All 4 recovery phases documented
  - Owner: Infrastructure Team

- [ ] RTO/RPO targets specified per system
  - Command: `cat /var/backup/runbooks/recovery-phases.md | grep -E "RTO|RPO"`
  - Success: RTO/RPO targets shown (critical 30m/5m, core 1h/15m, standard 4h/1h)
  - Owner: Infrastructure Team

- [ ] Recovery sequence dependencies mapped
  - Command: `cat /var/backup/runbooks/recovery-dependencies.yaml | head -20`
  - Success: Dependency graph showing which systems must restore first
  - Owner: Infrastructure Team

**Test 4b: Automated recovery runbook**
- [ ] Automated recovery workflow executable (shell or Python)
  - Command: `file /usr/local/bin/recover-infrastructure.sh`
  - Success: Identified as executable shell script or Python script
  - Owner: Infrastructure Team

- [ ] Automated recovery tested (dry-run mode)
  - Command: `/usr/local/bin/recover-infrastructure.sh --dry-run --phase 1`
  - Success: Dry-run completes with "success" status
  - Owner: Infrastructure Team

- [ ] Recovery runbook includes decision trees for failures
  - Command: `grep -i "if.*fail\|decision\|else" /usr/local/bin/recover-infrastructure.sh | wc -l`
  - Success: Multiple decision points present (≥ 5)
  - Owner: Infrastructure Team

**Test 4c: Manual recovery runbook**
- [ ] Manual recovery procedures documented step-by-step
  - Command: `cat /var/backup/runbooks/manual-recovery.md | grep -E "^###" | head -10`
  - Success: Multiple procedural sections documented
  - Owner: Infrastructure Team

- [ ] Verification steps defined for each recovery phase
  - Command: `grep -E "Verify|Check|Test" /var/backup/runbooks/manual-recovery.md | wc -l`
  - Success: ≥ 20 verification steps documented
  - Owner: Infrastructure Team

- [ ] Escalation paths and contact information included
  - Command: `grep -E "Escalate|Contact|Phone|Email" /var/backup/runbooks/manual-recovery.md | wc -l`
  - Success: ≥ 5 escalation/contact sections
  - Owner: Infrastructure Team

**Test 4d: Recovery testing**
- [ ] Monthly disaster recovery drill scheduled and completed
  - Command: `backup-cli drill list --type monthly --days 30 | head -1`
  - Success: Monthly drill found in past 30 days
  - Owner: Infrastructure Team

- [ ] Quarterly full disaster recovery test executed
  - Command: `backup-cli drill list --type quarterly --days 90 | head -1`
  - Success: Quarterly test found in past 90 days
  - Owner: Infrastructure Team

- [ ] DR test timing documented and reviewed
  - Command: `backup-cli drill show --id $(backup-cli drill list --type quarterly --days 90 | head -1 | awk '{print $1}') | grep -E "duration|phase_timing"`
  - Success: Timing shown and compared to RTO targets
  - Owner: Infrastructure Team

- [ ] Team trained on disaster recovery procedures
  - Command: `cat /var/backup/training/attendance.log | grep -E "2026-0[89]|2026-09" | wc -l`
  - Success: Training attendance ≥ 90% of team in past 2 months
  - Owner: HR/Training Team

---

### Skill 5: Backup Storage Management

**Test 5a: Storage target configuration**
- [ ] Primary storage configured with versioning enabled
  - Command: `aws s3api get-bucket-versioning --bucket backup-primary --endpoint-url https://minio.internal:9000 | grep -i "Status"`
  - Success: Returns "Status": "Enabled"
  - Owner: Infrastructure Team

- [ ] Secondary storage configured with cross-region replication
  - Command: `aws s3api get-bucket-replication --bucket backup-secondary --endpoint-url https://aws.s3.amazonaws.com | grep -i "ReplicationConfiguration"`
  - Success: Replication configuration present
  - Owner: Infrastructure Team

- [ ] Cold storage configured as WORM (immutable)
  - Command: `aws s3api get-object-lock-configuration --bucket backup-cold --endpoint-url https://aws.s3.amazonaws.com | grep -i "ObjectLockEnabled"`
  - Success: Returns "ObjectLockEnabled": "Enabled"
  - Owner: Infrastructure Team

- [ ] Failover mechanism configured (automatic redirect)
  - Command: `cat /etc/backup-agent/config.yaml | grep -A3 "failover" | head -5`
  - Success: Failover configuration shows auto-redirect on primary failure
  - Owner: Infrastructure Team

**Test 5b: Deduplication and compression**
- [ ] Backup deduplication enabled and operational
  - Command: `backup-cli dedup status`
  - Success: Deduplication shows "operational" with current ratio
  - Owner: Infrastructure Team

- [ ] Deduplication ratio meets target (>5:1)
  - Command: `backup-cli dedup status | grep -i "ratio" | awk '{print $NF}' | tr -d ':1' | awk '$1 > 5 {print "PASS"} $1 <= 5 {print "FAIL"}'`
  - Success: Returns "PASS" (ratio > 5:1)
  - Owner: Infrastructure Team

- [ ] Compression enabled (ZSTD before encryption)
  - Command: `cat /etc/backup-agent/config.yaml | grep -i "compression\|zstd"`
  - Success: Compression enabled with ZSTD codec
  - Owner: Infrastructure Team

- [ ] Compression ratio measured (>30%)
  - Command: `backup-cli compression stats | grep -i "ratio" | awk '{print $NF}' | tr -d '%' | awk '$1 > 30 {print "PASS"} $1 <= 30 {print "FAIL"}'`
  - Success: Returns "PASS" (compression > 30%)
  - Owner: Infrastructure Team

**Test 5c: Lifecycle and retention management**
- [ ] Lifecycle rules configured and running
  - Command: `aws s3api get-bucket-lifecycle-configuration --bucket backup-primary --endpoint-url https://minio.internal:9000 | grep -i "Rules"`
  - Success: Lifecycle rules configured
  - Owner: Infrastructure Team

- [ ] Hot-to-warm transition after 7 days verified
  - Command: `backup-cli lifecycle list | grep -i "hot.*warm" | grep "7.*day"`
  - Success: Transition rule found: hot 7 days → warm
  - Owner: Infrastructure Team

- [ ] Warm-to-cold transition after 30 days verified
  - Command: `backup-cli lifecycle list | grep -i "warm.*cold" | grep "30.*day"`
  - Success: Transition rule found: warm 30 days → cold
  - Owner: Infrastructure Team

- [ ] Compliance retention enforced (7 years minimum)
  - Command: `backup-cli policy list | grep -i compliance | grep -E "2555|365" | wc -l`
  - Success: Shows ≥ 2555 days (7 years)
  - Owner: Compliance Team

- [ ] Automatic deletion working (old backups removed)
  - Command: `backup-cli lifecycle log --action delete --days 7 | wc -l`
  - Success: Deletion events logged (≥ 1 in past 7 days)
  - Owner: Infrastructure Team

**Test 5d: Geographic distribution and replication**
- [ ] Multi-region replication configured
  - Command: `aws s3api get-bucket-replication --bucket backup-secondary --endpoint-url https://aws.s3.amazonaws.com | grep -i "DestinationRegion"`
  - Success: Destination region shown (different from source)
  - Owner: Infrastructure Team

- [ ] Replication lag monitored (target < 4 hours)
  - Command: `backup-cli replication status | grep -i "lag"`
  - Success: Shows lag time (should be < 4 hours)
  - Owner: Infrastructure Team

- [ ] Cross-region replication lag acceptable
  - Command: `backup-cli replication status | grep -i "lag" | awk '{lag=$NF; gsub(/[^0-9.]/,"",lag); if (lag < 240) print "PASS"; else print "FAIL"}'`
  - Success: Returns "PASS" (< 240 minutes = 4 hours)
  - Owner: Infrastructure Team

- [ ] Network redundancy for replication
  - Command: `ip route show | grep backup | wc -l`
  - Success: Shows multiple backup routes (≥ 2)
  - Owner: Network Team

**Test 5e: Storage performance and monitoring**
- [ ] Storage metrics collection running
  - Command: `backup-cli metrics status | grep -i "collecting\|operational"`
  - Success: Metrics shown as operational
  - Owner: Infrastructure Team

- [ ] Backup write performance SLA (>100MB/sec)
  - Command: `backup-cli metrics show --metric write_speed --last 7 | awk 'NR>1 {sum+=$2; n++} END {avg=sum/n; if (avg > 100) print "PASS"; else print "FAIL"}'`
  - Success: Returns "PASS" (average > 100MB/sec)
  - Owner: Infrastructure Team

- [ ] Restore speed SLA (>200MB/sec)
  - Command: `backup-cli metrics show --metric read_speed --last 7 | awk 'NR>1 {sum+=$2; n++} END {avg=sum/n; if (avg > 200) print "PASS"; else print "FAIL"}'`
  - Success: Returns "PASS" (average > 200MB/sec)
  - Owner: Infrastructure Team

- [ ] Storage latency SLA (< 5 seconds)
  - Command: `backup-cli metrics show --metric latency --last 7 | awk 'NR>1 {max=$2; if (max < 5) print "PASS"; else print "FAIL"}'`
  - Success: Returns "PASS" (max latency < 5 seconds)
  - Owner: Infrastructure Team

---

### Skill 6: Disaster Recovery Runbooks & Automation

**Test 6a: Automated recovery workflows**
- [ ] Infrastructure-as-Code templates for recovery created
  - Command: `find /var/backup/terraform -name "*.tf" | wc -l`
  - Success: Shows ≥ 5 Terraform files
  - Owner: Infrastructure Team

- [ ] Runbook engine configured (Ansible/Terraform/Python)
  - Command: `which ansible || which terraform || which python3 | grep -v "^$" | wc -l`
  - Success: Shows ≥ 1 automation tool available
  - Owner: Infrastructure Team

- [ ] Parallel execution configured (N services simultaneously)
  - Command: `cat /var/backup/runbooks/recovery-parallel-jobs.yaml | grep -c "^  -" `
  - Success: Shows ≥ 5 parallelizable jobs
  - Owner: Infrastructure Team

- [ ] Health checks integrated after each recovery step
  - Command: `grep -c "health.*check\|verify.*health" /usr/local/bin/recover-infrastructure.sh`
  - Success: Shows ≥ 10 health check invocations
  - Owner: Infrastructure Team

- [ ] Rollback capability implemented
  - Command: `grep -c "rollback\|revert\|checkpoint" /usr/local/bin/recover-infrastructure.sh`
  - Success: Shows ≥ 5 rollback points
  - Owner: Infrastructure Team

**Test 6b: Manual recovery documentation**
- [ ] Step-by-step recovery guide created
  - Command: `wc -l /var/backup/runbooks/manual-recovery-procedures.md | awk '{if ($1 > 500) print "PASS"; else print "FAIL"}'`
  - Success: Returns "PASS" (document > 500 lines)
  - Owner: Infrastructure Team

- [ ] Decision trees documented (if-then-else scenarios)
  - Command: `grep -c "If\|Then\|Else\|[Ff]ailover" /var/backup/runbooks/manual-recovery-procedures.md`
  - Success: Shows ≥ 10 decision points
  - Owner: Infrastructure Team

- [ ] Time estimates per step provided
  - Command: `grep -c "minutes\|seconds\|hours\|ETA" /var/backup/runbooks/manual-recovery-procedures.md`
  - Success: Shows time estimates for each major step
  - Owner: Infrastructure Team

- [ ] Cumulative RTO clearly stated
  - Command: `grep -i "total.*rto\|cumulative.*time" /var/backup/runbooks/manual-recovery-procedures.md`
  - Success: RTO total documented (should align with 30m/1h/4h targets)
  - Owner: Infrastructure Team

**Test 6c: Failure detection and escalation**
- [ ] Health checks running during recovery
  - Command: `grep -c "health_check\|monitor.*recovery" /usr/local/bin/recover-infrastructure.sh`
  - Success: Shows ≥ 5 health monitoring calls
  - Owner: Infrastructure Team

- [ ] Escalation policy configured (15/30/60 min escalation)
  - Command: `cat /etc/backup-agent/escalation-policy.yaml | grep -E "15|30|60" | head -3`
  - Success: Shows escalation thresholds at 15, 30, 60 minutes
  - Owner: Infrastructure Team

- [ ] Communication templates created
  - Command: `ls -1 /var/backup/templates/communication-*.txt | wc -l`
  - Success: Shows ≥ 3 communication templates (status update, alert, summary)
  - Owner: Infrastructure Team

- [ ] Graceful degradation mode available
  - Command: `grep -i "degraded.*mode\|fallback\|reduced.*capacity" /usr/local/bin/recover-infrastructure.sh`
  - Success: Degraded mode procedures present
  - Owner: Infrastructure Team

**Test 6d: Recovery dashboards**
- [ ] Real-time recovery dashboard deployed
  - Command: `curl -s http://recovery-dashboard.internal:3000 | grep -i "recovery\|progress" | head -1`
  - Success: Dashboard accessible and shows recovery content
  - Owner: Infrastructure Team

- [ ] Component status tracking on dashboard
  - Command: `curl -s http://recovery-dashboard.internal:3000/api/components | jq '.[] | .status' 2>/dev/null | head -3`
  - Success: Shows component status (pending/in-progress/succeeded/failed)
  - Owner: Infrastructure Team

- [ ] Recovery progress percentage tracking
  - Command: `curl -s http://recovery-dashboard.internal:3000/api/progress | jq '.completion_percent' 2>/dev/null`
  - Success: Returns percentage (0-100)
  - Owner: Infrastructure Team

- [ ] Resource utilization monitoring during recovery
  - Command: `curl -s http://recovery-dashboard.internal:3000/api/resources | jq '.cpu, .memory, .network' 2>/dev/null | head -3`
  - Success: Shows CPU, memory, network metrics
  - Owner: Infrastructure Team

**Test 6e: Recovery automation testing**
- [ ] Automated recovery test executed in past 30 days
  - Command: `backup-cli test list --type recovery-auto --days 30 | head -1`
  - Success: Automation test found in past 30 days
  - Owner: Infrastructure Team

- [ ] Failure injection test completed (network down scenario)
  - Command: `backup-cli test show --id $(backup-cli test list --type failure-injection --days 30 | head -1 | awk '{print $1}') | grep -i "network.*down\|connectivity.*fail"`
  - Success: Network failure scenario tested
  - Owner: Infrastructure Team

- [ ] Failure injection test completed (disk full scenario)
  - Command: `backup-cli test show --id $(backup-cli test list --type failure-injection --days 30 | grep "disk" | head -1 | awk '{print $1}') | grep -i "disk.*full"`
  - Success: Disk full scenario tested
  - Owner: Infrastructure Team

- [ ] Performance profiling completed (recovery time per component)
  - Command: `backup-cli profile list --type recovery --days 90 | head -1`
  - Success: Recovery performance profile found in past 90 days
  - Owner: Infrastructure Team

---

## Integration Validation

### Upstream Integrations (Storage & Backup is foundational - no upstream dependencies)
- [ ] No upstream dependencies for Storage & Backup Agent
  - Confirmation: N/A (foundational Phase 1 component)
  - Owner: Infrastructure Team

### Downstream Integration Points

**Security & Secrets Agent Integration**
- [ ] Vault backup integration configured
  - Command: `backup-cli job list --component vault | grep -i "schedule\|enabled"`
  - Success: Vault backup job scheduled and enabled
  - Owner: Infrastructure Team

- [ ] Vault escrow key backup stored separately
  - Command: `ls -la /var/backup/escrow/ | wc -l`
  - Success: Shows 5+ escrow key backups
  - Owner: Security Team

- [ ] Vault recovery procedure tested
  - Command: `backup-cli test list --type vault-recovery --days 30 | head -1`
  - Success: Vault recovery test found in past 30 days
  - Owner: Infrastructure Team

**Database Agent Integration**
- [ ] Database backup coordination with Database Agent
  - Command: `backup-cli job list --component database | grep -i "coordinate\|sync"`
  - Success: Shows coordination with database service
  - Owner: Database Team

- [ ] Database consistency pre-checks before backup
  - Command: `grep -i "consistency\|DBCC\|pg_dump" /usr/local/bin/backup-database.sh | head -3`
  - Success: Consistency checks present
  - Owner: Database Team

**Docker Agent Integration**
- [ ] Container image backup configured
  - Command: `backup-cli job list --component container | head -1`
  - Success: Container backup job present
  - Owner: Docker Team

- [ ] Persistent volume backup configured
  - Command: `backup-cli job list --component volumes | head -1`
  - Success: Volume backup job present
  - Owner: Docker Team

**Configuration Management Integration**
- [ ] Configuration file backup scheduled
  - Command: `backup-cli job list --component config | head -1`
  - Success: Configuration backup scheduled
  - Owner: DevOps Team

- [ ] Configuration recovery procedure tested
  - Command: `backup-cli test list --type config-recovery --days 30 | head -1`
  - Success: Config recovery test found in past 30 days
  - Owner: DevOps Team

**Audit & Compliance Integration**
- [ ] Audit log backup scheduled and isolated
  - Command: `backup-cli job list --component audit-logs | head -1`
  - Success: Audit log backup present (separate from other backups)
  - Owner: Audit Team

- [ ] Compliance reports generated and accessible
  - Command: `backup-cli report list --type compliance | head -3`
  - Success: Multiple compliance reports available
  - Owner: Compliance Team

---

## Operational Validation

### Startup Procedure
- [ ] Storage & Backup Agent starts within 15 minutes
  - Command: `time systemctl start backup-agent && systemctl is-active backup-agent`
  - Success: Service started in < 15 min, shows "active"
  - Owner: Infrastructure Team

- [ ] All backup targets verified accessible on startup
  - Command: `tail -20 /var/log/backup-agent/startup.log | grep -i "target.*accessible\|verified"`
  - Success: All targets verified in startup log
  - Owner: Infrastructure Team

- [ ] Backup scheduler initialized with all policies loaded
  - Command: `backup-cli job list | wc -l`
  - Success: Shows > 10 backup jobs loaded
  - Owner: Infrastructure Team

- [ ] Health checks passing after startup
  - Command: `curl -s https://backup-agent.internal:5000/health | jq '.status'`
  - Success: Returns "healthy"
  - Owner: Infrastructure Team

### Shutdown Procedure
- [ ] No in-progress backups killed abruptly (graceful shutdown)
  - Command: `tail -10 /var/log/backup-agent/shutdown.log | grep -i "graceful\|complete\|success"`
  - Success: Shows graceful shutdown message
  - Owner: Infrastructure Team

- [ ] Backup cache flushed to storage
  - Command: `tail -10 /var/log/backup-agent/shutdown.log | grep -i "cache.*flush\|persisted"`
  - Success: Shows cache flush message
  - Owner: Infrastructure Team

- [ ] No storage locks held after shutdown
  - Command: `etcdctl get /backup/locks/ 2>/dev/null | grep -i key | wc -l`
  - Success: Returns 0 (no locks held)
  - Owner: Infrastructure Team

### Performance Validation
- [ ] Backup completion within 6-hour window
  - Command: `backup-cli report show --type performance --date today | grep -i "duration" | awk '{if ($NF < 360) print "PASS"; else print "FAIL"}'`
  - Success: Returns "PASS" (< 360 minutes = 6 hours)
  - Owner: Infrastructure Team

- [ ] No backup impacts production traffic
  - Command: `sar -n DEV 1 60 | grep -i backup | awk '{if ($NF < 50) print "PASS"; else print "FAIL"}'`
  - Success: Returns "PASS" (backup traffic < 50% of capacity)
  - Owner: Network Team

- [ ] Memory usage stable (no memory leaks)
  - Command: `free -h && sleep 3600 && free -h | diff - <(free -h) | grep -i "Mem"`
  - Success: Memory usage difference < 1%
  - Owner: Infrastructure Team

### Monitoring & Health Checks
- [ ] Daily automated health check running at 5 AM UTC
  - Command: `grep -E "2026-09-16.*05:0[0-5]" /var/log/backup-agent/health-check.log | head -1`
  - Success: Health check run logged around 5 AM UTC
  - Owner: Infrastructure Team

- [ ] Weekly health review completed by infrastructure team
  - Command: `ls -lt /var/backup/reports/health-review-*.txt | head -1 | awk '{print $6, $7, $8}'`
  - Success: Shows date within past 7 days
  - Owner: Infrastructure Team

- [ ] No critical errors in backup logs (past 24 hours)
  - Command: `grep -i "ERROR\|CRITICAL" /var/log/backup-agent/*.log | grep -v "^Binary" | wc -l`
  - Success: Returns 0 critical errors
  - Owner: Infrastructure Team

---

## Security Validation

### Authentication & Authorization
- [ ] Backup service account with minimal permissions configured
  - Command: `getent passwd backup-agent`
  - Success: User backup-agent exists
  - Owner: Security Team

- [ ] Backup API requires authentication (no anonymous access)
  - Command: `curl -s https://backup-agent.internal:5000/backup | grep -i "unauthorized\|401\|forbidden"`
  - Success: Returns authentication error
  - Owner: Security Team

- [ ] Service account credentials rotated quarterly
  - Command: `cat /var/backup/audit/credential-rotation.log | grep -E "2026-0[6-9]|2026-1[0-2]" | tail -1 | grep -i "rotate"`
  - Success: Recent rotation logged
  - Owner: Security Team

### Encryption
- [ ] Encryption at rest: All backups encrypted with AES-256-GCM
  - Command: `backup-cli list --limit 1 --show-encryption | grep -i "AES-256\|GCM"`
  - Success: Shows AES-256-GCM encryption
  - Owner: Security Team

- [ ] Encryption in transit: TLS 1.2+ enforced for all connections
  - Command: `openssl s_client -connect backup-agent.internal:5000 -tls1_2 < /dev/null | grep "Protocol\|TLSv"`
  - Success: Shows TLSv1.2 or higher
  - Owner: Security Team

- [ ] Backup encryption key separate from primary vault
  - Command: `vault auth list | grep -i "backup\|approle" | wc -l`
  - Success: Shows separate auth mechanism for backup
  - Owner: Security Team

- [ ] Encryption key rotation scheduled and tested
  - Command: `cat /etc/backup-agent/config.yaml | grep -A2 "key_rotation" | grep -i "schedule\|annual"`
  - Success: Annual rotation configured
  - Owner: Security Team

### Access Control
- [ ] Only authorized users can view backup contents
  - Command: `backup-cli list --user unauthorized-user 2>&1 | grep -i "denied\|unauthorized\|forbidden"`
  - Success: Returns access denied
  - Owner: Security Team

- [ ] Only authorized users can initiate restores
  - Command: `backup-cli restore --user unauthorized-user --dry-run 2>&1 | grep -i "denied\|unauthorized\|forbidden"`
  - Success: Returns access denied
  - Owner: Security Team

- [ ] Backup API access logged (audit trail)
  - Command: `grep -i "api.*access\|request.*received" /var/log/backup-agent/audit.log | wc -l`
  - Success: Shows > 100 audit entries
  - Owner: Audit Team

### Audit Logging
- [ ] All backup operations logged with timestamp and operator
  - Command: `tail -20 /var/log/backup-agent/audit.log | grep -i "user\|timestamp\|operation"`
  - Success: Shows operator and timestamp for each operation
  - Owner: Audit Team

- [ ] All restore operations logged
  - Command: `grep -i "restore" /var/log/backup-agent/audit.log | head -3 | grep -i "user\|timestamp"`
  - Success: Restore operations logged with user/time
  - Owner: Audit Team

- [ ] All encryption key operations logged
  - Command: `grep -i "key.*rotation\|key.*access" /var/log/backup-agent/audit.log | head -3`
  - Success: Key operations logged
  - Owner: Security Team

---

## Compliance Validation

### SOC2 Type II Controls
- [ ] Backup access control procedures documented
  - Command: `wc -l /var/backup/compliance/SOC2-access-control.md`
  - Success: File > 100 lines
  - Owner: Compliance Team

- [ ] Backup change management procedures documented
  - Command: `wc -l /var/backup/compliance/SOC2-change-management.md`
  - Success: File > 100 lines
  - Owner: Compliance Team

- [ ] Backup audit logging procedures documented
  - Command: `wc -l /var/backup/compliance/SOC2-audit-logging.md`
  - Success: File > 100 lines
  - Owner: Compliance Team

### ISO 27001 Controls
- [ ] Encryption controls documented and tested
  - Command: `grep -c "encryption" /var/backup/compliance/ISO27001-controls.md`
  - Success: > 10 references to encryption controls
  - Owner: Compliance Team

- [ ] Access control policies documented
  - Command: `grep -c "access.*control\|RBAC" /var/backup/compliance/ISO27001-controls.md`
  - Success: > 10 references to access controls
  - Owner: Compliance Team

### PCI-DSS Compliance
- [ ] Sensitive data encryption at rest verified
  - Command: `backup-cli encryption status | grep -i "AES-256\|encrypted"`
  - Success: Shows encryption enabled
  - Owner: Compliance Team

- [ ] Sensitive data encryption in transit verified
  - Command: `openssl s_client -connect backup-agent.internal:5000 -tls1_2 < /dev/null | grep -i "Cipher"`
  - Success: Shows strong cipher (not anon/NULL)
  - Owner: Compliance Team

- [ ] Secure deletion procedures documented
  - Command: `wc -l /var/backup/compliance/PCI-DSS-deletion.md`
  - Success: File > 50 lines
  - Owner: Compliance Team

---

## Disaster Recovery Validation

### Backup & Recovery
- [ ] Daily backups executing successfully
  - Command: `backup-cli job log --component all --days 1 --status success | wc -l`
  - Success: Shows ≥ 5 successful backups in past 24h
  - Owner: Infrastructure Team

- [ ] Weekly full backups completing successfully
  - Command: `backup-cli job log --component all --type full --status success | head -1 | grep -i "success"`
  - Success: Recent full backup successful
  - Owner: Infrastructure Team

- [ ] Incremental backup chain intact (all backups present)
  - Command: `backup-cli chain verify --days 7 | grep -i "valid\|intact"`
  - Success: Chain verification passed
  - Owner: Infrastructure Team

- [ ] Point-in-time recovery capability verified
  - Command: `backup-cli pitr list | head -3 | grep -i "available"`
  - Success: Multiple PITR windows available
  - Owner: Infrastructure Team

### Disaster Recovery Testing
- [ ] Monthly DR drill executed (Phase 1 recovery)
  - Command: `backup-cli drill list --type monthly --days 30 | head -1`
  - Success: Monthly drill found in past 30 days
  - Owner: Infrastructure Team

- [ ] Quarterly full DR test executed (all phases)
  - Command: `backup-cli drill list --type quarterly --days 90 | head -1`
  - Success: Quarterly test found in past 90 days
  - Owner: Infrastructure Team

- [ ] DR test results within RTO targets
  - Command: `backup-cli drill show --id $(backup-cli drill list --type quarterly --days 90 | head -1 | awk '{print $1}') | grep -i "rto\|duration" | grep -E "(30|60|240).*min"`
  - Success: Test completed within RTO targets
  - Owner: Infrastructure Team

- [ ] DR test report signed by infrastructure lead
  - Command: `backup-cli drill show --id $(backup-cli drill list --type quarterly --days 90 | head -1 | awk '{print $1}') | grep -i "approved_by"`
  - Success: Report shows approval
  - Owner: Infrastructure Team

### Key Escrow & Recovery
- [ ] Key escrow procedure tested (3-of-5 access)
  - Command: `ls -la /var/backup/escrow/test-results/ | tail -5`
  - Success: Recent escrow test files present
  - Owner: Security Team

- [ ] Key recovery successful (verified key functionality)
  - Command: `cat /var/backup/escrow/test-results/latest-recovery-test.log | grep -i "success\|passed"`
  - Success: Recovery test passed
  - Owner: Security Team

---

## Constraints Verification

**Constraint 1: Backup window < 6 hours**
- [ ] Backup completion time monitored weekly
  - Command: `backup-cli report show --type performance --last-7-days | grep -i "duration" | awk '{if ($NF < 360) print "PASS"; else print "FAIL"}'`
  - Owner: Infrastructure Team

**Constraint 2: RPO < 15 minutes**
- [ ] Transaction log backup interval set to 15 minutes
  - Command: `backup-cli job list --component database | grep -i "transaction\|log" | grep "15.*min"`
  - Owner: Database Team

**Constraint 3: RTO critical < 30 minutes**
- [ ] Critical services recovery time < 30 minutes (tested)
  - Command: `backup-cli drill show --id $(backup-cli drill list --type quarterly --days 90 | head -1 | awk '{print $1}') | grep -i "critical.*30\|phase.*1.*30"`
  - Owner: Infrastructure Team

**Constraint 4: RTO core < 1 hour**
- [ ] Core services recovery time < 1 hour (tested)
  - Command: `backup-cli drill show --id $(backup-cli drill list --type quarterly --days 90 | head -1 | awk '{print $1}') | grep -i "core.*60\|phase.*2.*60"`
  - Owner: Infrastructure Team

**Constraint 5: RTO standard < 4 hours**
- [ ] Standard services recovery time < 4 hours (tested)
  - Command: `backup-cli drill show --id $(backup-cli drill list --type quarterly --days 90 | head -1 | awk '{print $1}') | grep -i "standard.*240\|phase.*3.*240"`
  - Owner: Infrastructure Team

**Constraint 6: Storage growth < 20% monthly**
- [ ] Storage usage growth monitored
  - Command: `backup-cli metrics show --metric storage_used --last-30-days | tail -2 | awk '{print}' | xargs -I {} expr $(tail -1) - $(head -1) | awk '{if ($1 < 20) print "PASS"; else print "FAIL"}'`
  - Owner: Infrastructure Team

**Constraint 7: Deduplication > 5:1**
- [ ] Deduplication ratio maintained above 5:1
  - Command: `backup-cli dedup status | grep -i "ratio" | awk '{print $NF}' | tr -d ':1' | awk '$1 > 5 {print "PASS"}'`
  - Owner: Infrastructure Team

**Constraint 8: Replication lag < 4 hours**
- [ ] Secondary replication lag within 4-hour window
  - Command: `backup-cli replication status | grep -i "lag" | awk '{lag=$NF; gsub(/[^0-9.]/,"",lag); if (lag < 240) print "PASS"}'`
  - Owner: Infrastructure Team

**Constraint 9: Compliance retention 7 years**
- [ ] Compliance backups retained for 7+ years
  - Command: `backup-cli policy list | grep -i compliance | grep -E "2555|365" | awk '{print $NF}' | awk '$1 >= 2555 {print "PASS"}'`
  - Owner: Compliance Team

**Constraint 10: Key rotation annually**
- [ ] Key rotation scheduled and tested annually
  - Command: `cat /etc/backup-agent/config.yaml | grep -A1 "key_rotation" | grep -i "annual"`
  - Owner: Security Team

**Constraint 11: Multi-region failover < 5 minutes**
- [ ] Failover mechanism tested and verified < 5 min
  - Command: `cat /var/backup/tests/failover-test-results.log | grep -i "duration\|complete" | grep -E "[0-4].*min"`
  - Owner: Infrastructure Team

**Constraint 12: Recovery automation tested monthly**
- [ ] Monthly recovery automation drill
  - Command: `backup-cli drill list --type monthly --days 30 | wc -l`
  - Success: Shows ≥ 1 monthly drill
  - Owner: Infrastructure Team

---

## Sign-Off & Approval

### Pre-Deployment Sign-Off

**Infrastructure Lead**:
- [ ] Validates backup infrastructure architecture
- [ ] Confirms all backup targets operational
- [ ] Approves network and storage configuration
- Signature: ___________________________ Date: __________

**Security Lead**:
- [ ] Validates encryption key management
- [ ] Confirms key escrow procedure tested
- [ ] Approves access control policies
- Signature: ___________________________ Date: __________

**Storage & Infrastructure Owner** (Database, Docker, etc.):
- [ ] Confirms backup sources configured
- [ ] Validates backup schedule for each system
- [ ] Approves recovery procedures
- Signature: ___________________________ Date: __________

**Compliance Officer**:
- [ ] Validates retention policies meet regulatory requirements
- [ ] Confirms audit logging enabled
- [ ] Approves compliance controls
- Signature: ___________________________ Date: __________

### Post-Deployment Sign-Off

**Installation & Configuration**:
- [ ] All checks passed
- Validated By: _____________________ Date: __________

**Skills Validation**:
- [ ] All 6 skills validated and operational
- Validated By: _____________________ Date: __________

**Integration Validation**:
- [ ] Downstream integrations tested (Security & Secrets, Database, Docker, etc.)
- Validated By: _____________________ Date: __________

**Operational Validation**:
- [ ] Startup/shutdown procedures working
- [ ] Performance within SLA
- Validated By: _____________________ Date: __________

**Security Validation**:
- [ ] Authentication/authorization enforced
- [ ] Encryption verified
- [ ] Audit logging operational
- Validated By: _____________________ Date: __________

**Compliance Validation**:
- [ ] SOC2, ISO27001, PCI-DSS controls verified
- [ ] Retention policies enforced
- Validated By: _____________________ Date: __________

**Disaster Recovery Validation**:
- [ ] Backup/restore procedures tested
- [ ] Key escrow tested
- [ ] RTO/RPO targets met
- Validated By: _____________________ Date: __________

### Final Production Readiness

**Overall Status**: ⚪ Not Ready / 🟡 Conditional / 🟢 Ready

**Readiness Criteria**:
- [ ] All validation checklist items passed (≥95%)
- [ ] All critical issues resolved
- [ ] All team members trained
- [ ] Runbooks complete and tested
- [ ] Monitoring and alerting operational

**Final Sign-Off**:

Infrastructure Manager: __________________ Date: __________

CTO/VP Engineering: __________________ Date: __________

**Notes/Issues**:
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

---

**Version**: 1.0  
**Last Updated**: 2026-09-16  
**Next Review Date**: 2026-10-16
