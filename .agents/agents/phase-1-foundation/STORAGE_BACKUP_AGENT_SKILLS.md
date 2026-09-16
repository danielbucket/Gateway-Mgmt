# Storage & Backup Agent Skills

**Status**: 🟡 TODO  
**Phase**: Phase 1 - Foundation  
**Timeline**: Weeks 1-2  
**Owner**: Infrastructure Team  
**Last Updated**: 2026-09-16

---

## Overview

The Storage & Backup Agent provides centralized backup and disaster recovery capabilities for the entire gateway management infrastructure. This agent is the foundation for data protection, ensuring all critical systems, configurations, and secrets can be recovered within defined RTO/RPO targets. It manages backup policies, retention schedules, verification procedures, and provides recovery orchestration across the entire 23-agent ecosystem.

### Core Responsibilities

- Design and implement backup infrastructure (storage targets, retention policies, schedules)
- Execute scheduled backups for all system components (databases, configurations, secrets vault)
- Manage incremental and full backup cycles with deduplication
- Verify backup integrity through periodic restore testing
- Maintain backup encryption keys separate from primary vault
- Coordinate disaster recovery procedures across all dependent agents
- Monitor backup success rates, duration, and storage consumption
- Automate backup rotation and compliance-based retention
- Provide point-in-time recovery capabilities for critical systems
- Enable disaster recovery testing without production impact
- Track backup SLAs and alert on deviations
- Manage geographic distribution of backups for resilience
- Support immutable backup storage for compliance requirements
- Document and test recovery procedures for all protected systems

### Integration Points

- **Upstream Dependencies**: None (foundational Phase 1 component)
- **Downstream Integrations**: All 22 other agents depend on this for data protection (Security & Secrets Agent vault backups, Configuration Management, Database backups, etc.)
- **External Integrations**: S3-compatible storage (MinIO or AWS S3), NAS/SMB targets, tape archive (optional), SFTP/SSH backup transfer

---

## Skills Matrix

Total Skills: 6 | Validation Items: ~24 | Constraints: ~12

| # | Skill Name | Description | Status | Difficulty |
|---|---------|-------------|--------|------------|
| 1 | Backup Infrastructure Design & Setup | Design multi-target backup architecture with retention policies | 🟡 | High |
| 2 | Automated Backup Orchestration | Configure scheduled backups across all system components | 🟡 | High |
| 3 | Backup Verification & Testing | Implement integrity checks and periodic restore testing | 🟡 | Medium |
| 4 | Disaster Recovery Coordination | Design and test recovery procedures for critical systems | 🟡 | High |
| 5 | Backup Storage Management | Manage storage targets, deduplication, and compliance | 🟡 | Medium |
| 6 | Disaster Recovery Runbooks & Automation | Create and automate recovery procedures with decision trees | 🟡 | High |

### Skill Categories

**Core Operations** (Skills #1-2)
- Skill 1: Backup Infrastructure Design & Setup - Multi-target architecture with failover
- Skill 2: Automated Backup Orchestration - Coordinated scheduling across all components

**Reliability & Verification** (Skills #3-4)
- Skill 3: Backup Verification & Testing - Integrity validation and restore testing
- Skill 4: Disaster Recovery Coordination - Cross-system recovery orchestration

**Storage & Compliance** (Skills #5-6)
- Skill 5: Backup Storage Management - Multi-target deduplication and retention
- Skill 6: Disaster Recovery Runbooks & Automation - Recovery automation and procedures

---

## Detailed Skill Descriptions

### Skill 1: Backup Infrastructure Design & Setup

**Purpose**: Establish robust backup architecture supporting all 23 agents with multiple targets, encryption, retention policies, and geographic distribution for compliance and resilience.

**Key Procedures**:

1. **Design backup architecture**
   - Identify all backup targets: Primary (on-premise NAS/S3), Secondary (off-site S3), Tertiary (cold storage/tape)
   - Specify retention tiers: Hot (7 days, daily), Warm (30 days, weekly), Cold (365 days, monthly)
   - Map critical systems to recovery objectives: Database (RTO 1h/RPO 15m), Vault (RTO 30m/RPO 5m), Configs (RTO 2h/RPO 1h)
   - Design encryption: Separate backup encryption key (not in primary vault), KMS-backed key management
   - Plan geographic distribution: Primary and secondary backups in different availability zones

2. **Configure storage targets**
   - Primary target: S3-compatible storage (MinIO cluster or AWS S3) with versioning enabled
   - Secondary target: Off-site S3 or Azure Blob Storage with geo-redundancy
   - Cold storage: WORM (Write-Once-Read-Many) storage for compliance (tape or cold S3 tier)
   - Bandwidth management: Throttle backup traffic to avoid production impact
   - Network paths: Direct private connection to backup targets, encrypted channels

3. **Establish retention policies**
   - Daily backups: Retain for 7 days (RPO window)
   - Weekly backups: Retain for 4 weeks (1 month retention)
   - Monthly backups: Retain for 12 months (1 year archive)
   - Regulatory backups: Keep for 7 years (compliance requirement)
   - Automated expiration: Delete expired backups, preserve compliance-tagged backups
   - Immutable hold: Apply 30-day immutable hold on compliance backups

4. **Implement encryption framework**
   - Generate backup encryption master key (256-bit AES-GCM)
   - Store master key in external HSM or separate vault instance
   - Use key derivation for individual backup encryption
   - Implement key rotation: Annual rotation with pre-rotation testing
   - Document key escrow: 5 offline copies stored securely with 3-of-5 access requirement

**Validation Items**:
- [ ] Backup infrastructure designed with all 3 tiers (hot, warm, cold)
- [ ] Primary S3 target configured with versioning and access logging
- [ ] Secondary off-site target configured and tested for connectivity
- [ ] Cold storage (WORM) configured for 7-year compliance retention
- [ ] Encryption master key generated and securely stored (HSM or external vault)
- [ ] Key escrow procedure tested with 3-of-5 access successful
- [ ] Retention policies defined and automated via lifecycle rules
- [ ] Bandwidth limits configured (max 500MB/sec during business hours)
- [ ] Network connectivity tested to all 3 backup targets
- [ ] DNS resolution tested for all backup endpoints

**Common Issues & Troubleshooting**:

- **Issue**: S3 target unreachable during backup window
  - **Cause**: Network connectivity issue, S3 endpoint down, credentials expired
  - **Solution**: Verify network path, check S3 status, rotate credentials, retry backup with exponential backoff
  - **Prevention**: Monitor backup target connectivity continuously, alert on failures

- **Issue**: Encryption key corrupted or inaccessible
  - **Cause**: HSM failure, key escrow not available, backup during key rotation
  - **Solution**: Retrieve key from escrow (3-of-5 access), restore HSM, cancel rotation and retry
  - **Prevention**: Test key escrow quarterly, monitor HSM health, implement key redundancy

- **Issue**: Backup storage quota exceeded, new backups failing
  - **Cause**: Retention policy not enforced, deduplication disabled, unexpected growth
  - **Solution**: Manually delete oldest backups, enable deduplication, expand storage capacity
  - **Prevention**: Monitor storage usage weekly, alert at 80% capacity, forecast growth trends

**Related Skills**: Skill 2 (Orchestration), Skill 3 (Verification), Skill 5 (Storage Management)

---

### Skill 2: Automated Backup Orchestration

**Purpose**: Implement reliable, coordinated backup scheduling for all system components (databases, configurations, vault secrets, binary artifacts) with dependency management and failure recovery.

**Key Procedures**:

1. **Configure backup scheduler**
   - Primary schedule: Daily full backups at 2 AM UTC (off-peak), incremental backups every 6 hours
   - Database backups: Full backup weekly (Sunday 1 AM), daily incremental (all days), transaction log backups every 15 minutes
   - Vault snapshots: Every 4 hours (RPO 4h requirement), plus on-demand before major changes
   - Configuration snapshots: Every 6 hours plus after any deployment (trigger-based)
   - Distributed agents: Staggered start times to avoid thundering herd (30-min window for 100+ services)

2. **Implement dependency management**
   - Sequence: Storage & Backup ready → Backup Vault (empty) → Configure backup policies → Backup Vault data
   - Wait conditions: Verify source system available before backup, verify target accessible before write
   - Rollback procedure: If backup fails, log event, retry exponentially (5s, 10s, 30s, 1m, 5m), alert on 5th failure
   - Coordination: Use distributed coordinator (etcd/Consul) to prevent duplicate backups and manage locks

3. **Configure backup agents**
   - Database agent: Use native backup tools (mysqldump for MySQL, pg_dump for PostgreSQL, mongodump for MongoDB)
   - Vault agent: Use Vault integrated storage API or Raft snapshot export
   - Configuration agent: Tarball `/etc/` and service configurations, encrypt with backup key
   - Application data: Use rsync or S3 sync for incremental transfer, implement checksum verification
   - Container images: Export to registry or S3 for immutable storage

4. **Implement failure handling**
   - Pre-check: Verify source/target connectivity, disk space, permissions before backup
   - Timeout: Set per-component timeout (DB 1h, Vault 30m, Configs 10m), abort and alert if exceeded
   - Retry logic: Failed backups retry 3x with exponential backoff over 15 minutes
   - Notification: Alert on each retry, then team escalation on final failure
   - Metrics: Track backup duration, size, success rate per component and target

**Validation Items**:
- [ ] Backup scheduler running and logging all scheduled jobs
- [ ] Database full backup running weekly, incremental backups running daily
- [ ] Vault snapshots captured every 4 hours
- [ ] Configuration backups captured every 6 hours
- [ ] Backup agents distributed across multiple nodes (no single point of failure)
- [ ] Dependency management preventing concurrent backups of same source
- [ ] Pre-backup checks passing for all components (connectivity, disk space, permissions)
- [ ] Timeout configured per component (DB 1h, Vault 30m, Configs 10m, app data 2h)
- [ ] Failure alerts triggered on 1st failure, escalated on 3rd failure
- [ ] Backup scheduling logs reviewed (no missed backups in past 7 days)
- [ ] Staggered scheduling preventing resource exhaustion (no peak load > 500MB/sec)
- [ ] Exponential backoff retry working (verified via intentional failure)

**Common Issues & Troubleshooting**:

- **Issue**: Backup took 2 hours but timeout is 1 hour, backup killed mid-stream
  - **Cause**: Timeout too aggressive, data growth exceeded expectations, network congestion
  - **Solution**: Increase timeout for this component, run backup during off-peak, enable deduplication
  - **Prevention**: Monitor backup duration trends, increase timeout before peak seasons

- **Issue**: Multiple backup agents trying to backup same database simultaneously
  - **Cause**: Scheduler not respecting dependency locks, agents started manually
  - **Solution**: Verify lock manager running, wait for concurrent backup to complete, restart scheduler
  - **Prevention**: Use distributed coordinator (etcd) with mandatory lock acquisition, monitor lock contention

- **Issue**: Backup completed but data looks incomplete (only 10GB instead of expected 100GB)
  - **Cause**: Incremental backup only captured deltas, previous full backup missing, filtering rule applied
  - **Solution**: Verify previous full backup exists, re-run full backup, check filter rules
  - **Prevention**: Implement checksum verification, alert on unexpected size changes (>20% variance)

**Related Skills**: Skill 1 (Infrastructure), Skill 3 (Verification), Skill 4 (DR Coordination)

---

### Skill 3: Backup Verification & Testing

**Purpose**: Implement comprehensive verification procedures to ensure backup integrity, recoverability, and compliance through automated testing and periodic restore validation.

**Key Procedures**:

1. **Automated verification procedures**
   - Backup manifest check: Verify backup contains all expected files, checksums match source
   - Integrity verification: Run backup integrity tool (e.g., Bareos verify job, S3 object integrity check)
   - Encryption verification: Verify backup encrypted with correct key, can be decrypted
   - Retention verification: Check backup lifecycle enforced, expired backups deleted, compliant backups retained
   - Restore simulation: Extract small subset of backup, verify data integrity without full restore
   - Size sanity check: Verify backup size within expected range (alert if >20% variance from baseline)

2. **Periodic restore testing**
   - Frequency: Test restore procedures monthly, test actual restore quarterly (on non-production system)
   - Database restore: Restore to standby system, verify all tables present, run consistency checks
   - Vault restore: Restore to test vault instance, verify all secrets present and readable
   - Configuration restore: Restore config files, verify syntax valid, services start correctly
   - Full system restore: Quarterly test full infrastructure recovery (if resources available)
   - Document results: Create restore test report with timing, issues found, and fixes applied

3. **Backup discovery and inventory**
   - Catalog all backups: Maintain central inventory of all backups (source, date, size, retention class)
   - Tag backups: Label backups (e.g., "database-prod-daily", "vault-event-snapshot")
   - Track lineage: Maintain full backup chain (which incremental builds on which full backup)
   - Inventory verification: Weekly reconciliation between backup metadata and actual backup objects
   - Search capability: Enable searching backups by date range, component, retention class

4. **Compliance documentation**
   - Evidence collection: Generate backup verification reports (date, component, size, checksum)
   - Chain of custody: Document who performed restore testing, when, results
   - Audit trail: Maintain immutable log of all backup operations and verification activities
   - Regulatory reports: Generate monthly compliance reports (GDPR, SOC2, PCI-DSS requirements)
   - Deletion requests: Implement secure deletion with proof of destruction

**Validation Items**:
- [ ] Backup manifest integrity check passing for 100% of backups
- [ ] Encryption verification confirming all backups encrypted with correct key
- [ ] Retention policy verification confirming lifecycle rules enforced
- [ ] Monthly restore simulation running successfully (subset data)
- [ ] Quarterly full restore test documented with timing and issues
- [ ] Backup discovery system operational (catalog, search, lineage tracking)
- [ ] Weekly inventory reconciliation completed with zero discrepancies
- [ ] Compliance reports generated and reviewed (SOC2, PCI-DSS, etc.)
- [ ] Deletion procedures tested (verify secure deletion working)
- [ ] Restore test reports signed by infrastructure lead and compliance officer

**Common Issues & Troubleshooting**:

- **Issue**: Restore test failed - database inconsistencies detected after restore
  - **Cause**: Incremental backup chain broken, corruption during backup, backup tool bug
  - **Solution**: Restore from previous full backup, verify incremental chain valid, run DBCC CHECKDB
  - **Prevention**: Run DBCC CHECKDB before and after restore, monitor restore test results

- **Issue**: Backup manifest shows 500GB but actual S3 object shows 200GB (discrepancy)
  - **Cause**: Deduplication reducing actual size, manifest includes all versions/snapshots, compression applied
  - **Solution**: Verify deduplication running, check manifest calculation, confirm backup complete
  - **Prevention**: Document expected compression ratio, monitor deduplication effectiveness

- **Issue**: Compliance report shows 20 backups should have been deleted but still present
  - **Cause**: Lifecycle rule not running, immutable hold preventing deletion, retention class misconfigured
  - **Solution**: Verify lifecycle job running, check for immutable holds, fix retention class tags
  - **Prevention**: Monitor deletion logs, alert on lifecycle failures, weekly manual verification

**Related Skills**: Skill 1 (Infrastructure), Skill 2 (Orchestration), Skill 4 (DR Coordination)

---

### Skill 4: Disaster Recovery Coordination

**Purpose**: Design, document, test, and automate disaster recovery procedures for all critical systems with defined RTO/RPO targets, decision trees, and cross-system coordination.

**Key Procedures**:

1. **Design disaster recovery procedures**
   - Map recovery sequence: Restore storage infrastructure → Restore backup vault → Restore all agent systems (depends on upstream completion)
   - Define recovery phases: Phase 1 (critical infrastructure 30min), Phase 2 (core services 1h), Phase 3 (supporting services 4h), Phase 4 (non-critical services 24h)
   - Document decisions: Pre-disaster (communication, staging), during (triage, prioritization), post (validation, hand-off)
   - Communication plan: Notify stakeholders every 15min during recovery, weekly progress updates during 24h recovery
   - Escalation paths: Team lead → Infrastructure manager → CTO (escalate every 1h of unresolved issues)

2. **Create disaster recovery runbooks**
   - Automated runbook (executable): Shell scripts or Python automation to execute recovery steps
   - Manual runbook (documented): Step-by-step procedures for human execution, including verification steps
   - Decision trees: "If X failed, try Y; if still failing, escalate to Z"
   - Rollback procedures: For each recovery step, define rollback if discovery of critical issue
   - Contact information: Team member names/phone/email for each recovery phase

3. **Test disaster recovery procedures**
   - Monthly drill: Execute partial recovery (Phase 1 only) in test environment, document timing
   - Quarterly test: Full 4-phase recovery test with actual data restore (non-production only)
   - Failure injection: Intentionally break components during test (network failure, storage corruption)
   - Team training: All team members participate in quarterly DR test, practice communication
   - Document results: Recovery test report including timing, issues, lessons learned

4. **Implement recovery automation**
   - Backup system restoration: Automated restore of backup infrastructure from off-site backup
   - Service restoration: Automated orchestration to restore services in dependency order
   - Health monitoring: Continuous health checks during recovery, alert on failures
   - Progress tracking: Dashboard showing recovery percentage, estimated completion time
   - Graceful degradation: If service can't be restored, fall back to read-only or limited mode

**Validation Items**:
- [ ] Disaster recovery procedures documented with clear recovery phases and RTO/RPO targets
- [ ] Recovery sequence defined and validated (all dependencies captured)
- [ ] Decision trees created for each failure scenario (network down, storage corrupted, etc.)
- [ ] Automated recovery runbook created and tested (shell scripts or Python)
- [ ] Manual recovery runbook created with step-by-step procedures
- [ ] Communication plan documented (notification templates, escalation paths)
- [ ] Contact list updated with all team members (name/phone/email)
- [ ] Monthly DR drill executed in past 30 days with documented results
- [ ] Quarterly full DR test executed in past quarter with actual data restore
- [ ] DR test report reviewed and signed by infrastructure lead and CTO
- [ ] Rollback procedures tested for each recovery phase
- [ ] Team training completed for all infrastructure staff (100% participation)

**Common Issues & Troubleshooting**:

- **Issue**: Recovery runbook executed but service still down, runbook incomplete
  - **Cause**: Runbook missing dependency check, undocumented manual step, environmental difference
  - **Solution**: Execute manual runbook step-by-step, identify missing step, add to automated runbook
  - **Prevention**: Test runbook in clean environment, have manual runbook as backup, version control runbooks

- **Issue**: Recovery taking 2 hours but RTO target is 1 hour
  - **Cause**: Backup size larger than expected, network bandwidth constrained, sequential steps should be parallel
  - **Solution**: Parallelize restore steps, identify bottleneck (network/disk/compute), scale infrastructure
  - **Prevention**: Monitor backup sizes, test network bandwidth, profile recovery steps, optimize critical path

- **Issue**: During recovery test, discovered backup chain broken (incremental backup missing full)
  - **Cause**: Full backup failed without alerting, retention policy deleted full backup, backup agent bug
  - **Solution**: Restore from next previous full backup, verify backup chain integrity, re-run full backup
  - **Prevention**: Monitor for broken chains, alert on missing full backups, test recovery monthly

**Related Skills**: Skill 2 (Orchestration), Skill 3 (Verification), Skill 5 (Storage Management)

---

### Skill 5: Backup Storage Management

**Purpose**: Manage multiple backup storage targets with deduplication, lifecycle policies, geographic distribution, and compliance while optimizing cost and performance.

**Key Procedures**:

1. **Configure storage targets and failover**
   - Primary storage: S3-compatible (MinIO on NAS or AWS S3) with synchronous replication
   - Secondary storage: Off-site S3 (AWS or Azure) with asynchronous replication (4-hour delay)
   - Cold storage: WORM storage (Glacier or tape) for compliance backups with 90-day minimum hold
   - Failover mechanism: Automatic redirect to secondary if primary unavailable for >5 minutes
   - Bandwidth replication: Secondary replication throttled to 50MB/sec to avoid primary impact

2. **Implement deduplication and compression**
   - Backup-level deduplication: Block-level deduplication with content-addressable storage
   - Deduplication ratio target: 10:1 (50GB raw data → 5GB after deduplication)
   - Compression: ZSTD compression (before encryption) for additional 30-50% space savings
   - Deduplication window: Sliding window of 30 days (compare blocks within 30-day window)
   - Storage monitoring: Track deduplication ratio weekly, alert if drops below 5:1

3. **Manage lifecycle and retention**
   - Lifecycle rules: Hot (7 days, S3 standard) → Warm (30 days, S3-IA) → Cold (365 days, Glacier)
   - Compliance retention: Immutable 30-day hold on all SOC2/PCI-DSS backups, minimum 7-year retention
   - Automatic deletion: Delete expired backups after retention period (prevent accidental deletion with warnings)
   - Manual hold: Ability to manually hold backup indefinitely (for investigation, litigation hold)
   - Reporting: Monthly lifecycle report showing compliance with retention policies

4. **Ensure geographic distribution and resilience**
   - Multi-region strategy: Primary in local data center, secondary in different geographic region
   - Cross-region replication: Automatic replication with 4-hour lag, monitored for lag > 6 hours
   - Bandwidth management: Replicate only backup deltas (incremental), compress before transfer
   - Disaster resilience: Survive loss of entire region (replicate to 3rd region if budget allows)
   - Network redundancy: Use multiple ISPs for backup replication, failover on primary ISP down

5. **Monitor storage performance and costs**
   - Storage metrics: Monitor usage per backup type (DB, Vault, Config), growth rate, dedup ratio
   - Performance SLAs: Backup write speed >100MB/sec, restore speed >200MB/sec, verify <5 sec latency
   - Cost optimization: Monthly cost analysis, recommend consolidation or tiering changes
   - Capacity planning: Forecast storage needs based on growth trends, 6-month runway planning
   - Chargeback reporting: Allocate storage costs to business units for cost accountability

**Validation Items**:
- [ ] Primary storage target configured with synchronous replication
- [ ] Secondary storage target configured and replication working (lag <4 hours)
- [ ] Cold storage (WORM) configured with 30-day minimum hold enforcement
- [ ] Failover mechanism working (tested by stopping primary, verifying redirect to secondary)
- [ ] Backup-level deduplication enabled, ratio measured at >5:1
- [ ] Compression enabled (ZSTD), compression ratio measured at >30%
- [ ] Lifecycle rules configured and enforced (hot → warm → cold transitions working)
- [ ] Retention policies enforced (immutable holds on compliance backups)
- [ ] Multi-region replication working, lag < 4 hours
- [ ] Bandwidth throttling working (secondary replication < 50MB/sec)
- [ ] Storage metrics collected and monitored (dashboards created)
- [ ] Capacity forecast completed and 6-month runway verified

**Common Issues & Troubleshooting**:

- **Issue**: Deduplication ratio dropped from 10:1 to 3:1, storage growing rapidly
  - **Cause**: Deduplication window too small, backup data changed significantly, dedup engine failing
  - **Solution**: Increase dedup window to 60 days, check for compression errors, restart dedup engine
  - **Prevention**: Monitor dedup ratio daily, alert if drops >20%, profile data changes

- **Issue**: Replication lag growing from 4 hours to 12+ hours, at risk of data loss
  - **Cause**: Network congestion, bandwidth limit too low, remote storage congested
  - **Solution**: Increase bandwidth allocation, reduce backup size, add parallel replication streams
  - **Prevention**: Monitor replication lag continuously, alert at 6-hour threshold, provision for 2x capacity

- **Issue**: Compliance audit found backup missing immutable hold, was deleted before retention period
  - **Cause**: Lifecycle rule misconfigured, immutable hold not applied, deletion ran before hold
  - **Solution**: Restore from secondary backup, re-apply immutable hold, verify lifecycle rules
  - **Prevention**: Implement mandatory immutable hold before backup considered valid, test lifecycle rules

**Related Skills**: Skill 1 (Infrastructure), Skill 3 (Verification), Skill 4 (DR Coordination)

---

### Skill 6: Disaster Recovery Runbooks & Automation

**Purpose**: Create executable disaster recovery automation and documentation enabling rapid recovery of all critical systems with minimal manual intervention and team parallelization.

**Key Procedures**:

1. **Create automated recovery workflows**
   - Infrastructure-as-Code: Define recovery procedures as Terraform/Ansible/CloudFormation templates
   - Runbook engine: Use workflow automation tool (Ansible, Terraform, custom Python) to execute recovery
   - Parallel execution: Execute independent recovery steps in parallel (N services simultaneously)
   - Health checks: After each step, verify health before proceeding (fail-fast on issues)
   - Rollback support: Track state of each recovery step, enable rollback to checkpoint
   - Logging: Log all recovery actions to immutable, off-site logging system

2. **Document manual recovery procedures**
   - Step-by-step guides: Written procedures for each recovery phase, targeting non-expert execution
   - Decision trees: If X fails, follow path Y; if still failing, follow path Z
   - Verification steps: After each major step, specify verification to confirm success
   - Time estimates: Document expected time per step, cumulative RTO
   - Appendices: Include common issues, troubleshooting, escalation contacts

3. **Implement failure detection and escalation**
   - Continuous monitoring: Health checks running during recovery, alert on failures immediately
   - Escalation policy: 15min unresolved → page team lead; 30min → page manager; 1hour → page CTO
   - Communication: Send status update every 15 minutes during recovery to all stakeholders
   - Decision matrix: Document when to escalate vs. when to retry, when to take alternate path
   - Graceful degradation: Ability to restore in reduced-capacity mode if full recovery blocked

4. **Create recovery dashboards and tracking**
   - Real-time dashboard: Show recovery percentage, current phase, estimated completion time
   - Component status: Per-system recovery status (pending, in-progress, succeeded, failed)
   - Resource utilization: Monitor CPU/memory/network during recovery (alert on exhaustion)
   - Alert integration: Critical alerts from recovery tools feed into team dashboard
   - Post-recovery reporting: Generate summary report (duration, issues, root causes)

5. **Test and validate automation**
   - Automated test runner: Monthly test of recovery automation (dry-run mode where possible)
   - Failure injection: Test recovery under various failure scenarios (network down, disk full, etc.)
   - Performance profiling: Measure recovery time per component, identify bottlenecks
   - Team validation: Have team members execute manual runbook quarterly
   - Documentation sync: Keep automated runbooks and manual docs in sync

**Validation Items**:
- [ ] Automated recovery workflows created using IaC (Terraform/Ansible/CloudFormation)
- [ ] Runbook engine configured and tested (can execute basic recovery workflow)
- [ ] Parallel execution implemented (independent steps run simultaneously)
- [ ] Health checks integrated into recovery workflow (fail-fast on issues)
- [ ] Rollback capability implemented and tested
- [ ] Recovery logging configured (immutable, off-site)
- [ ] Manual recovery procedures documented with decision trees and verification steps
- [ ] Manual procedures include time estimates per step and cumulative RTO
- [ ] Escalation policy documented (15min/30min/1hour escalation to leads/manager/CTO)
- [ ] Communication templates created (status updates, incident summary)
- [ ] Recovery dashboard created and tested (shows real-time progress)
- [ ] Component status tracking implemented (pending/in-progress/succeeded/failed)
- [ ] Automated recovery test executed and documented in past 30 days
- [ ] Failure injection testing completed (tested 3+ failure scenarios)
- [ ] Manual runbook executed by team members in quarterly DR test

**Common Issues & Troubleshooting**:

- **Issue**: Automated recovery workflow failed at step 5, manual workaround executed, recovery took 2 hours
  - **Cause**: Workflow missing dependency check, undocumented environmental difference, timing issue
  - **Solution**: Execute manual recovery, investigate failure, add missing steps to automation
  - **Prevention**: Test automation in clean environment, have manual runbook as backup, version control

- **Issue**: Recovery dashboard showing 50% complete but actual recovery only 20% (metrics wrong)
  - **Cause**: Metrics calculation error, phase overlap not accounted for, estimation inaccurate
  - **Solution**: Fix metric calculations, re-baseline phase timings, update dashboard
  - **Prevention**: Validate dashboard calculations quarterly, compare actual vs. estimated times

- **Issue**: During recovery, team unable to execute manual runbook (procedures unclear/incomplete)
  - **Cause**: Runbook assumes knowledge, missing steps, poor organization
  - **Solution**: Rewrite runbook for operators (not experts), add decision tree, clarify each step
  - **Prevention**: Have non-expert team member review runbook, test with fresh eyes

**Related Skills**: Skill 2 (Orchestration), Skill 4 (DR Coordination), Skill 5 (Storage Management)

---

## Validation Checklist

✅ **Infrastructure Validation** (~24 items total):

### Pre-Deployment
- [ ] Backup targets identified (primary, secondary, cold storage)
- [ ] Storage capacity calculated (estimated 10-50% of total data)
- [ ] Network connectivity tested to all backup targets
- [ ] Encryption keys generated and securely stored
- [ ] Key escrow procedure documented and tested (3-of-5 access)
- [ ] Retention policies defined per backup tier (hot/warm/cold)
- [ ] Deduplication and compression settings configured

### Infrastructure Setup
- [ ] Primary backup storage configured and tested (S3-compatible or NAS)
- [ ] Secondary off-site storage configured and replication working
- [ ] Cold storage (WORM) configured with immutable hold enforcement
- [ ] Backup encryption keys stored and backed up (separate from primary vault)
- [ ] Failover mechanism configured (automatic switch to secondary on failure)
- [ ] Bandwidth limits enforced (no backup impacts production traffic)

### Orchestration & Scheduling
- [ ] Backup scheduler running and logging all jobs
- [ ] Database backups scheduled (full weekly, incremental daily, transaction log 15min)
- [ ] Vault snapshots scheduled (every 4 hours, plus on-demand)
- [ ] Configuration backups scheduled (every 6 hours, plus after deployments)
- [ ] Backup agents distributed (not all on single node)
- [ ] Pre-backup checks passing (connectivity, disk space, permissions)
- [ ] Timeout configured per component (DB 1h, Vault 30m, Configs 10m)

### Verification & Testing
- [ ] Backup manifest integrity checks passing for 100% of backups
- [ ] Monthly restore simulation running successfully
- [ ] Quarterly full restore test documented with timing and issues
- [ ] Backup discovery system operational (catalog, search, lineage)
- [ ] Weekly inventory reconciliation completed (zero discrepancies)

---

## Constraints & Limits

⚠️ **Critical Constraints** (~12 total):

| Constraint | Value | Reason | Mitigation |
|-----------|-------|--------|-----------|
| Backup window | 6 hours max | Must complete before business hours | Parallel backups, deduplication |
| RPO target | 15 minutes | Data loss limited to recent 15 min of transactions | Frequent transaction log backups |
| RTO target (Critical) | 30 minutes | Business critical services restored quickly | Pre-staged recovery infrastructure |
| RTO target (Core) | 1 hour | Core services restored within 1 hour | Prioritized recovery sequence |
| RTO target (Standard) | 4 hours | Standard services within 4 hours | Phased recovery approach |
| Backup storage growth | <20% monthly | Storage costs predictable and controlled | Deduplication target 10:1, compression |
| Deduplication minimum | 5:1 ratio | Space savings must be predictable | Monitor weekly, alert if drops >20% |
| Replication lag | <4 hours | Secondary always within 4-hour window | Throttled async replication |
| Retention compliance | 7 years | SOC2/PCI-DSS requirement | Immutable hold enforcement |
| Encryption key rotation | Annually | Security requirement | Pre-rotation testing, key escrow |
| Multi-region failover | <5 minutes | Automatic failover on primary unavailable | Continuous health monitoring |
| Recovery automation test | Monthly | Ensure recovery procedures work | Schedule monthly DR drills |

---

## Architecture & Design

### Deployment Model

**Primary Location**: On-premise NAS or S3-compatible storage (MinIO cluster)  
**Backup Location**: Off-site cloud storage (AWS S3, Azure Blob, or second data center)  
**Cold Storage**: WORM storage (Glacier or tape archive) in secure facility  
**Network Requirements**: Backup network (isolated VLAN), encrypted channels (TLS 1.2+), private connectivity to cloud  
**Resource Requirements**: 
- Backup coordinator: 2 CPU cores, 4GB RAM, 100GB disk
- Storage targets: Minimum 500GB available (grows with 10:1 dedup ratio)
- Network: Dedicated backup network 1Gbps minimum, 10Gbps recommended for large backups

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    Backup Ecosystem                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────┐      ┌──────────────────────────┐   │
│  │  Source Systems      │      │  Backup Orchestrator     │   │
│  ├──────────────────────┤      ├──────────────────────────┤   │
│  │ • Databases (MySQL)  │      │ • Scheduler (Cron/APScheduler)
│  │ • Vault (Secrets)    │  ←→  │ • Dependency Manager    │   │
│  │ • Configs            │      │ • Health Checks         │   │
│  │ • Docker Images      │      │ • Failure Handling      │   │
│  │ • Application Data   │      │ • Metrics Collection    │   │
│  └──────────────────────┘      └──────────────────────────┘   │
│           ↓                               ↓                    │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │        Backup Processing Pipeline                        │ │
│  ├──────────────────────────────────────────────────────────┤ │
│  │ 1. Pre-check (connectivity, permissions)                │ │
│  │ 2. Backup execution (native tools: mysqldump, pg_dump)  │ │
│  │ 3. Deduplication (content-addressable storage)          │ │
│  │ 4. Compression (ZSTD before encryption)                 │ │
│  │ 5. Encryption (AES-256-GCM with backup key)             │ │
│  │ 6. Verification (manifest + integrity check)            │ │
│  └──────────────────────────────────────────────────────────┘ │
│           ↓                               ↓                    │
│  ┌─────────────────────┐    ┌──────────────────────────────┐ │
│  │  Hot Storage (7d)   │    │  Warm Storage (30d)          │ │
│  ├─────────────────────┤    ├──────────────────────────────┤ │
│  │ Primary:            │    │ Secondary:                   │ │
│  │ • MinIO (S3 compat) │    │ • AWS S3 Std-IA              │ │
│  │ • On-premise NAS    │ ←→ │ • Azure Blob Tier 2          │ │
│  │ • Versioning ON     │    │ • Async replication (4h lag) │ │
│  │ • Sync replication  │    │ • Failover target            │ │
│  └─────────────────────┘    └──────────────────────────────┘ │
│           ↓                               ↓                    │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │  Cold Storage (365d → 7y)                                │ │
│  ├──────────────────────────────────────────────────────────┤ │
│  │ • AWS Glacier or Tape Archive                            │ │
│  │ • WORM (Write-Once-Read-Many) enforcement                │ │
│  │ • Immutable 30-day hold on compliance backups            │ │
│  │ • 7-year minimum retention for SOC2/PCI-DSS             │ │
│  └──────────────────────────────────────────────────────────┘ │
│                                                                 │
│  ┌──────────────────────┐      ┌──────────────────────────┐   │
│  │  Verification &      │      │  Monitoring & Alerting   │   │
│  │  Recovery Testing    │      │                          │   │
│  ├──────────────────────┤      ├──────────────────────────┤   │
│  │ • Manifest check     │      │ • Backup success rate    │   │
│  │ • Restore simulation │      │ • Storage usage trends   │   │
│  │ • Monthly drills     │      │ • Dedup ratio (target 10:1)
│  │ • Quarterly full     │      │ • Replication lag (target <4h)
│  │   restore test       │      │ • Recovery time tracking │   │
│  └──────────────────────┘      └──────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

Disaster Recovery Workflow:
┌─────────────────┐    ┌─────────────────┐    ┌──────────────┐
│  Phase 1        │    │  Phase 2        │    │  Phase 3     │
│  Critical       │ → │  Core Services  │ → │  Supporting  │
│  Infrastructure │    │  (Vault, DB)    │    │  Services    │
│  (30 min RTO)   │    │  (1 hour RTO)   │    │  (4 hour RTO)│
└─────────────────┘    └─────────────────┘    └──────────────┘
        ↓                      ↓                      ↓
   1. Restore backup   1. Restore database   1. Restore configs
   2. Restore vault    2. Restore vault      2. Restore app data
   3. Restore configs  3. Health checks      3. Validation
   4. Basic tests      4. Service startup
```

### Integration with Other Agents

**Upstream Dependencies**: None (foundational Phase 1 component - no dependencies)

**Downstream Dependencies**: 
- **Security & Secrets Agent**: Requires Storage & Backup for vault data backup, escrow key backup
- **All 22 other agents**: Require backup capability for their data and configurations
- **Database Agent**: Coordinates database backup scheduling and restore procedures
- **Docker Agent**: Backs up container images and persistent volumes
- **Configuration Management**: Backs up all configuration files and IaC templates
- **Audit & Logging**: Backs up audit logs and compliance records

**Data Flow**:
1. Source systems → Backup Orchestrator (metadata + data)
2. Backup Orchestrator → Backup Processing Pipeline (format, compress, encrypt)
3. Backup Pipeline → Primary Storage (hot backup)
4. Primary Storage → Secondary Storage (async replication, 4h lag)
5. Secondary Storage → Cold Storage (monthly transition to archive)
6. Cold Storage → Regulatory Vault (7-year retention for compliance)

**Event Integration**:
- **Backup events**: Generated after each backup completes (success/failure + metrics)
- **Recovery events**: Generated during DR procedures (phase start/completion + status)
- **Alerting**: Integration with Prometheus/AlertManager for backup SLA violations
- **Audit logging**: All backup operations logged to central audit system

---

## Operations

### Startup Procedure

**Timeline**: 10-15 minutes to full operation

1. **Pre-startup checks** (2 minutes)
   - Verify primary storage accessible (ping endpoint, verify credentials)
   - Verify secondary storage accessible (ping endpoint, verify credentials)
   - Verify backup encryption key available (HSM or external vault)
   - Verify backup coordinator service not running (prevent duplicate)

2. **Start backup infrastructure** (5 minutes)
   - Start backup storage service (MinIO or NAS storage)
   - Verify storage health checks passing
   - Start backup orchestrator service
   - Verify scheduler initialized and running

3. **Initialize backup policies** (3 minutes)
   - Load retention policies from configuration
   - Initialize backup scheduling (mark jobs as pending)
   - Initialize deduplication and compression settings
   - Load source system credentials

4. **Final health verification** (2 minutes)
   - Test connectivity to all backup targets (primary, secondary, cold)
   - Verify backup encryption key accessible
   - Verify scheduler running (check process logs)
   - Mark Storage & Backup Agent as "ready"

### Shutdown Procedure

**Timeline**: 5-10 minutes graceful shutdown

1. **Graceful shutdown of backups** (3-5 minutes)
   - Cancel pending backup jobs (no new backups)
   - Wait for in-progress backups to complete (timeout 5 minutes)
   - Flush backup cache to storage
   - Close connections to all backup targets

2. **Backup infrastructure shutdown** (2-3 minutes)
   - Shutdown backup orchestrator service
   - Shutdown backup storage service
   - Verify all services stopped cleanly

3. **Verification** (1 minute)
   - Verify no storage locks held (check distributed coordinator)
   - Verify no open connections to backup targets
   - Backup Agent marked as "offline"

### Health Checks

**Automated Daily Health Check** (5 AM UTC):
- [ ] Primary storage accessible (test write + read)
- [ ] Secondary storage accessible (test read)
- [ ] Backup encryption key accessible
- [ ] Latest backup completed successfully (backup completed < 24 hours ago)
- [ ] Backup success rate > 95% (check last 30 days)
- [ ] Storage capacity available > 20% (alert if < 20%)
- [ ] Deduplication ratio > 5:1 (alert if < 5:1)
- [ ] Replication lag < 4 hours (alert if > 4h)
- [ ] No backup timeout errors in past 24 hours
- [ ] Restore test passed in past 30 days

**Manual Weekly Health Review** (Monday 9 AM UTC):
- Review backup success rate, identify failures
- Review storage usage trends, identify anomalies
- Review backup performance metrics, identify slowdowns
- Verify deduplication effectiveness
- Check for any backup timeout or security alerts
- Spot-check 3 random backups (verify data integrity)

### Regular Maintenance

**Weekly Tasks** (Every Monday):
- Review backup health report (success rates, storage usage, performance)
- Spot-check 3 random backups for integrity
- Verify replication lag < 4 hours
- Confirm 100% of critical backups succeeded
- Review backup logs for warnings/errors

**Monthly Tasks** (First Monday of month):
- Execute partial disaster recovery drill (Phase 1 recovery only)
- Test backup encryption key rotation (pre-rotation phase)
- Review compliance reports (SOC2, PCI-DSS, GDPR)
- Forecast storage capacity for next 3 months
- Review and update disaster recovery procedures

**Quarterly Tasks** (Every 3 months):
- Execute full disaster recovery test (all 4 phases)
- Rotate encryption keys if scheduled
- Review and update runbooks
- Team training on disaster recovery procedures
- Analyze backup trends, recommend optimizations

**Annual Tasks**:
- Audit backup compliance with retention policies
- Review and update recovery procedures
- Test key escrow access procedure (3-of-5 access)
- Capacity planning for next year
- Vendor/contract renewal (storage providers, tools)

### Updates & Patching

**Security Patches**: Apply immediately after testing (within 24 hours)
- High/Critical severity: Deploy same day after testing
- Medium severity: Deploy within 1 week
- Low severity: Deploy within 1 month

**Feature Updates**: Quarterly (aligned with Security & Secrets and other Phase 1 agents)
- Test update in staging environment (1 week)
- Schedule during maintenance window
- Update documentation after successful deployment

---

## Troubleshooting

### Common Issues & Solutions

#### Backup Failures

**Issue**: Backup failed to complete, timeout after 1 hour

**Root Cause Analysis**:
1. Source system unavailable/slow (database locked, network congestion)
2. Target storage unavailable (S3 endpoint down, network timeout)
3. Insufficient resources (CPU/memory/disk exhausted)
4. Timeout too aggressive for this backup size

**Resolution Steps**:
1. Check source system health (verify database running, check disk space)
2. Check target storage connectivity (ping S3 endpoint, verify credentials)
3. Monitor resource usage during backup (check CPU/memory/disk)
4. If timeout the cause, increase timeout for this component
5. Re-run backup manually to verify success

**Prevention**:
- Monitor backup duration trends, increase timeout before peak seasons
- Configure resource limits to prevent exhaustion (per-backup CPU/memory quotas)
- Alert on backup duration > baseline + 20%

---

**Issue**: Backup completed but size suspicious (only 1GB instead of expected 100GB)

**Root Cause Analysis**:
1. Incremental backup only (captured only deltas, not full data)
2. Filter rule applied (excluding large directories)
3. Previous full backup missing (no baseline for incremental)
4. Backup tool failure (partial data captured)

**Resolution Steps**:
1. Check backup type (full vs. incremental) - confirm expected
2. Verify previous full backup exists (not deleted)
3. Check for filter rules (verify expected directories included)
4. Run full backup to verify all data captured
5. Compare checksums before/after

**Prevention**:
- Alert on unexpected size changes (>20% variance from baseline)
- Implement checksum verification for all backups
- Test incremental backup chain weekly

---

**Issue**: Backup encryption failed - cannot encrypt with backup key

**Root Cause Analysis**:
1. Encryption key corrupted or inaccessible
2. HSM failure or connectivity issue
3. Key has wrong permissions (cannot use for encryption)
4. Backup key rotation in progress (key temporarily unavailable)

**Resolution Steps**:
1. Verify encryption key accessible (try to use key)
2. Check HSM/key server connectivity
3. Verify key permissions (encryption allowed)
4. Check for key rotation in progress (wait for completion)
5. If key corrupted, restore from escrow (3-of-5 access)

**Prevention**:
- Monitor HSM health continuously
- Test key access path regularly
- Alert on key access failures immediately
- Maintain key escrow for rapid recovery

---

#### Storage Issues

**Issue**: Storage capacity critically low (< 5% free), backup failing

**Root Cause Analysis**:
1. Deduplication not working (files duplicated)
2. Retention policy not enforced (old backups not deleted)
3. Unexpected data growth (backup larger than expected)
4. Compression disabled or not working

**Resolution Steps**:
1. Check deduplication status and ratio (verify working)
2. Check retention policy enforcement (verify old backups deleted)
3. Analyze backup sizes by component (identify growth source)
4. Manually delete oldest non-compliant backups (if needed)
5. Expand storage capacity or add new target

**Prevention**:
- Monitor storage usage weekly, alert at 80% capacity
- Forecast growth trends monthly
- Enable deduplication (target 10:1 ratio)
- Enforce retention policies automatically

---

**Issue**: Replication lag growing to 12+ hours (beyond 4-hour target)

**Root Cause Analysis**:
1. Network bandwidth insufficient (backup traffic overwhelming link)
2. Remote storage congested (not accepting writes quickly)
3. Backup size increased significantly
4. Bandwidth limit too low for current backup volume

**Resolution Steps**:
1. Check network utilization during replication
2. Check remote storage performance (latency, throughput)
3. Analyze recent backup sizes (compare to baseline)
4. Increase bandwidth allocation (if possible)
5. Consider reducing backup frequency or size

**Prevention**:
- Monitor replication lag continuously, alert at 6+ hours
- Provision bandwidth for 2x current backup volume
- Profile replication performance weekly
- Alert on unexpected lag increase

---

#### Recovery Issues

**Issue**: Restore test failed - database inconsistencies detected after restore

**Root Cause Analysis**:
1. Incremental backup chain broken (missing intermediate backup)
2. Corruption during backup or transfer
3. Backup tool failure
4. Database consistency issue at backup time

**Resolution Steps**:
1. Verify incremental backup chain intact
2. Restore from previous full backup (skip incremental)
3. Run database consistency check (DBCC CHECKDB or equivalent)
4. Compare backup checksum to source
5. Restore full backup to verify data integrity

**Prevention**:
- Run DBCC CHECKDB before and after restore
- Test restore chain weekly
- Monitor for backup corruption alerts

---

**Issue**: Disaster recovery runbook incomplete, recovery took 3 hours (target 1 hour)

**Root Cause Analysis**:
1. Runbook missing steps or dependencies
2. Verification steps taking longer than expected
3. Parallel steps executed sequentially by mistake
4. Unexpected issues requiring manual intervention

**Resolution Steps**:
1. Compare actual recovery to runbook steps
2. Identify missing or delayed steps
3. Update runbook with discovered steps
4. Profile each recovery step to identify bottlenecks
5. Parallelize where possible (independent services)

**Prevention**:
- Test runbook regularly (monthly)
- Have team members execute with stopwatch to measure timing
- Identify and parallelize independent recovery steps
- Test in clean environment quarterly

---

#### Verification Issues

**Issue**: Backup manifest shows 500GB but actual S3 object is 200GB

**Root Cause Analysis**:
1. Deduplication reducing actual stored size (expected!)
2. Manifest includes all versions/snapshots
3. Compression applied
4. Manifest calculation error

**Resolution Steps**:
1. Verify deduplication enabled (expected to see 2-3x reduction)
2. Check manifest calculation logic
3. Verify compression enabled (another 30-50% reduction)
4. Calculate expected size: raw size / (dedup ratio 10:1) / (compression 1.4:1) = final size
5. Compare calculation to actual

**Prevention**:
- Document expected compression ratio
- Maintain manifest and actual object size in monitoring
- Alert on unexpected discrepancies (> 20% variance)

---

### Escalation Paths

**Level 1 - Backup Team**:
- Backup failures (retry, manual intervention)
- Storage issues (expand capacity, clean up)
- Monitoring/alerting (tune thresholds)
- **Escalate if**: Issue unresolved after 15 minutes or requires infrastructure changes

**Level 2 - Infrastructure Lead**:
- Recovery runbook execution
- Storage architecture changes
- Network/connectivity issues
- **Escalate if**: Issue unresolved after 30 minutes or impacts production

**Level 3 - Infrastructure Manager**:
- Extended outage (> 1 hour without progress)
- Data integrity issues
- Compliance violations
- **Escalate if**: Recovery behind schedule or RTO at risk

**Level 4 - CTO**:
- Critical infrastructure failure
- Complete data loss scenario
- Major compliance incident
- **Escalate if**: RTO exceeded or data loss confirmed

---

## Monitoring & Alerting

### Key Metrics

**Backup Performance Metrics**:
- Backup duration per component (minutes) - baseline, alert if 2x baseline
- Backup size per component (GB) - trending, alert if >20% variance
- Backup success rate (%) - should be > 95%, alert if < 95%
- Backup throughput (MB/sec) - should be > 100MB/sec, alert if < 50MB/sec

**Storage Metrics**:
- Total storage used (GB) - track trending
- Storage utilization (%) - alert at 80% capacity
- Deduplication ratio - should be > 5:1, alert if < 5:1
- Compression ratio - should be > 30%, alert if < 20%

**Replication Metrics**:
- Replication lag (hours) - should be < 4h, alert if > 6h
- Replication throughput (MB/sec) - monitor for degradation
- Replication success rate (%) - should be 100%, alert on failures

**Recovery Metrics**:
- Last successful restore test (days ago) - should be < 30 days
- Restore time per component (minutes) - used for RTO planning
- Recovery runbook validation (days since test) - should be < 30 days
- Disaster recovery drill frequency - should be monthly

### Alert Rules

**SEV1 - Immediate Page**:
- [ ] Backup failure (3+ consecutive backups failed)
- [ ] Storage full (< 5% capacity remaining)
- [ ] Replication lag > 12 hours
- [ ] Encryption key inaccessible
- [ ] Primary + secondary storage both unavailable

**SEV2 - Team Alert**:
- [ ] Single backup failure (retry once, alert if repeats)
- [ ] Storage at 80% capacity
- [ ] Replication lag > 6 hours
- [ ] Deduplication ratio dropped to 3:1
- [ ] Monthly restore test missed (overdue)

**SEV3 - Monitoring Dashboard**:
- [ ] Backup duration > 2x baseline
- [ ] Storage utilization > 60%
- [ ] Replication lag > 4 hours
- [ ] Restore test completed > 30 days ago
- [ ] Backup throughput < 50MB/sec

### Dashboards

**Backup Overview Dashboard**:
- Backup status (last 7 days) - success/failure rate
- Storage used vs. capacity - trending chart
- Deduplication ratio - target 10:1
- Backup duration trends - baseline vs. actual
- Replication lag - target < 4 hours

**Recovery & Compliance Dashboard**:
- Last successful restore (date/time)
- Recovery time per component (SLA vs. actual)
- Compliance backups retained (SOC2, PCI-DSS)
- Disaster recovery drill history (dates, results)
- Key rotation history (last date, next date)

---

## Disaster Recovery

### Backup Recovery Procedures

**Recovery Objective**: Restore complete backup infrastructure from off-site backup within 2 hours

**Prerequisites**:
- Off-site backup of backup infrastructure configurations
- Backup encryption key available (or key escrow accessible)
- Secondary storage location accessible
- Recovery infrastructure (target nodes) available

**Phase 1: Restore Backup Infrastructure** (0-30 min)
1. Provision new backup coordinator node
2. Restore backup configurations from off-site backup
3. Mount secondary storage as primary (failover)
4. Initialize deduplication cache from checkpoint
5. Verify connectivity to all backup sources

**Phase 2: Restore Backup Data** (30-60 min)
1. Verify backup chain integrity (all incremental backups present)
2. Run full backup verification (manifest + integrity checks)
3. Restore key databases from backup
4. Restore vault from backup
5. Restore configurations from backup

**Phase 3: Validation** (60-120 min)
1. Verify all backed-up systems restored successfully
2. Run consistency checks on restored databases
3. Verify vault secrets accessible
4. Test restore procedures with sample data
5. Sign-off on recovery completion

**Rollback Procedure**: If recovery fails, fall back to previous backup location (if exists) or escalate to business continuity manager.

### Key Escrow Procedures

**Key Escrow Setup**:
- [ ] Generate backup encryption master key (256-bit AES)
- [ ] Split key into 5 shares using Shamir's Secret Sharing
- [ ] Distribute shares to 5 team members (in separate locations)
- [ ] Document recovery procedure (in sealed envelope)
- [ ] Test recovery (3-of-5 access) annually

**Key Recovery Procedure**:
1. Contact 3 of 5 key holders (in-person or video conference)
2. Each holder provides their share (must be present)
3. Combine shares using recovery tool (shamir reconstruct)
4. Verify recovered key matches original (test encryption/decryption)
5. Use recovered key to access backup encryption

---

## Security & Compliance

### Security Controls

**Data Protection**:
- [ ] Encryption at rest: AES-256-GCM with separate backup encryption key
- [ ] Encryption in transit: TLS 1.2+ for all network traffic
- [ ] Key rotation: Annual rotation with pre-rotation testing
- [ ] Key escrow: Shamir's Secret Sharing (3-of-5 access)

**Access Control**:
- [ ] RBAC: Only authorized users can initiate backups/restores
- [ ] Service accounts: Backup service account with minimal required permissions
- [ ] Audit logging: All backup operations logged with user/timestamp
- [ ] MFA: Required for manual backup/restore operations

**Compliance**:
- [ ] SOC2 Type II: Backup controls documented and tested
- [ ] ISO 27001: Encryption, access control, audit logging
- [ ] PCI-DSS: Sensitive data encrypted, retention policies enforced
- [ ] GDPR: Right to deletion supported (secure deletion with proof)

### Compliance Checklist

**Data Retention**:
- [ ] Retention policies defined and enforced per data classification
- [ ] Immutable hold enforced on compliance backups (30-day minimum)
- [ ] 7-year retention for SOC2/PCI-DSS backups
- [ ] Secure deletion procedure with proof of destruction
- [ ] Right to deletion supported (marked for deletion, securely overwritten)

**Audit & Logging**:
- [ ] All backup operations logged (start/stop/success/failure)
- [ ] All restore operations logged (who, when, what, result)
- [ ] All encryption key operations logged (generation/rotation/access)
- [ ] Audit logs immutable and sent to central logging system
- [ ] Compliance reports generated monthly

**Change Management**:
- [ ] All backup configuration changes tracked
- [ ] Backup procedure changes documented and approved
- [ ] Testing required before production deployment
- [ ] Rollback procedure documented for each change

---

## Team & Contacts

**Storage & Backup Agent Owner**: [To be assigned]
- Primary Contact: [Name/Phone/Email]
- Secondary Contact: [Name/Phone/Email]

**Infrastructure Team Lead**: [To be assigned]
- Primary Contact: [Name/Phone/Email]

**On-Call Rotation**: [Backup Team members, rotating weekly]
- Current On-Call: [Name/Phone]
- Next On-Call: [Name/Phone]

**Escalation Path**:
1. On-Call → Infrastructure Lead (if unresolved after 15 min)
2. Infrastructure Lead → Infrastructure Manager (if unresolved after 30 min)
3. Infrastructure Manager → CTO (if unresolved after 1 hour)

---

## Integration Examples

### CLI Operations

**List recent backups**:
```bash
# List last 10 backups with metadata
backup-cli list --limit 10 --sort date

# Filter backups by component and date range
backup-cli list --component database --from 2026-09-01 --to 2026-09-16
```

**Perform manual backup**:
```bash
# Backup specific component with custom retention
backup-cli backup --component database --target primary --retention 30days

# Backup with custom encryption key
backup-cli backup --component vault --encryption-key backup-master-key-v2
```

**Test restore without full recovery**:
```bash
# Restore single file from backup
backup-cli restore --backup-id backup-2026-09-15-01 --file /etc/config.yaml --to /tmp/restore-test

# Verify backup integrity before restore
backup-cli verify --backup-id backup-2026-09-15-01 --deep-check
```

**Manage retention and lifecycle**:
```bash
# Apply immutable hold to backup
backup-cli hold --backup-id backup-2026-09-15-01 --hold-days 30

# Manually transition backup to cold storage
backup-cli transition --backup-id backup-2026-01-15-01 --target cold-storage
```

### Python Application Integration

**Backup coordination from application code**:
```python
from backup_agent import BackupClient

# Initialize backup client
backup_client = BackupClient(
    endpoint="backup.internal:5000",
    api_key="backup-app-key-xxx",
    encryption_key="backup-master-key"
)

# Request application data backup
backup_response = backup_client.request_backup(
    component="my_app_data",
    backup_type="full",
    target="primary",
    retention_days=30
)

# Wait for backup to complete
backup_client.wait_for_backup(
    backup_id=backup_response.backup_id,
    timeout_seconds=3600
)

# Verify backup integrity
verification_result = backup_client.verify_backup(
    backup_id=backup_response.backup_id,
    deep_check=True
)
```

**Restore data from backup**:
```python
# Request specific backup restore
restore_request = backup_client.request_restore(
    backup_id="backup-2026-09-15-01",
    target_location="/var/lib/my_app/restored_data",
    verify_after_restore=True
)

# Wait for restore completion
restore_result = backup_client.wait_for_restore(
    restore_id=restore_request.restore_id,
    timeout_seconds=1800
)

# Validate restored data integrity
if restore_result.success:
    print(f"Restore completed in {restore_result.duration_seconds}s")
    print(f"Data integrity verified: {restore_result.checksum_match}")
```

---

## Files to Review for Reference

- **DEPLOYMENT_PROCEDURES.md**: 6-phase deployment workflow for all agents
- **AGENT_ROADMAP.md**: Phase 1-4 implementation timeline and dependencies
- **SECURITY_SECRETS_AGENT_SKILLS.md**: Security & Secrets Agent (downstream dependency)
- **VALIDATION_CHECKLIST_TEMPLATE.md**: Standard validation checklist format

---

## Known Limitations & Gotchas

**Performance Limitations**:
- Backup window limited to 6 hours (must complete before business hours)
- Backup throughput limited by network bandwidth (typically 100-500MB/sec)
- Restore throughput faster than backup (typically 200-1000MB/sec)
- Deduplication adds CPU/memory overhead (limit to 10GB/sec processing rate)

**Operational Quirks**:
- Incremental backups depend on full backup chain (if full backup deleted, incremental unusable)
- Key rotation requires careful coordination (backup key unavailable during rotation window)
- Encryption key escrow requires in-person access (cannot retrieve remotely)
- Cold storage writes are immutable (cannot delete until hold expires)

**Dependencies & Interactions**:
- Security & Secrets Agent depends on Storage & Backup Agent for vault backups
- All 22 other Phase 2+ agents depend on Storage & Backup for data protection
- Database Agent coordinates backup scheduling (to avoid locking/deadlocks)
- Audit & Compliance Agent tracks backup compliance and retention

**Known Issues**:
- S3 API compatibility issues with some MinIO versions (test thoroughly)
- Incremental backup chain can break if intermediate backup deleted (be careful with manual retention changes)
- Encryption key rotation window (30 min) creates brief window where new backups may fail (plan for off-peak)

---

## Status Summary

**Current Status**: 🟡 TODO (Phase 1, Week 1-2)

**Readiness for Deployment**:
- ✅ Skills documented comprehensively
- ✅ Validation procedures defined
- ✅ Architecture and integration designed
- ✅ Operations procedures documented
- ✅ Troubleshooting guides created
- ✅ Security & compliance framework established
- 🟡 Deployment procedures pending (Task 5 in roadmap)

**Next Steps**:
1. Create deployment procedures (adapt DEPLOYMENT_PROCEDURES.md for Storage & Backup)
2. Prepare deployment environment (storage targets, encryption keys, network paths)
3. Execute Phase 1 Week 1-2 deployment (parallel with Security & Secrets Week 2-3)
4. Run validation procedures (pre-deployment, skills, integration, operational, compliance)
5. Begin Phase 2 agent development (depends on Storage & Backup readiness)

---

**Last Updated**: 2026-09-16  
**Version**: 1.0  
**Approved By**: [Infrastructure Lead - Pending]
