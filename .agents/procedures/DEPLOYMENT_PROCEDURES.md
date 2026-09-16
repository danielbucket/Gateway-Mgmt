# Agent Deployment Procedures

This document describes the standardized procedures for deploying agents in the gateway management system.

---

## Deployment Phases Overview

```
Phase 1: Planning & Preparation
  ├─ Requirements review
  ├─ Resource allocation
  ├─ Dependency verification
  └─ Team briefing
         ↓
Phase 2: Pre-Deployment
  ├─ Environment preparation
  ├─ Configuration setup
  ├─ Backup creation
  └─ Rollback plan
         ↓
Phase 3: Deployment
  ├─ Upstream dependency check
  ├─ Agent installation
  ├─ Configuration deployment
  ├─ Service startup
  ├─ Initial health checks
  └─ Data flow verification
         ↓
Phase 4: Validation
  ├─ Run validation checklist
  ├─ Performance testing
  ├─ Escalation testing
  ├─ Security audit
  └─ Sign-off
         ↓
Phase 5: Post-Deployment
  ├─ Monitoring setup
  ├─ Alert testing
  ├─ Documentation update
  ├─ Team training
  └─ Production cutover
         ↓
Phase 6: Stabilization
  ├─ Monitor for issues
  ├─ Performance baseline
  ├─ Optimize if needed
  └─ Close deployment
```

---

## Phase 1: Planning & Preparation

### Requirements Review

**Checklist**:
- [ ] Agent roadmap phase complete (if phased deployment)
- [ ] Agent skills document finalized
- [ ] Integration requirements documented
- [ ] Upstream dependencies identified
- [ ] Downstream dependencies identified
- [ ] Resource requirements calculated
- [ ] Security requirements specified
- [ ] Compliance requirements identified

**Review Meeting**:
- [ ] Attended by: [Roles needed]
- [ ] Duration: [Estimate: 1-2 hours]
- [ ] Outcome: [Sign-off on requirements]

### Resource Allocation

**Team Assignment**:
- **Lead Developer**: [Name/Role]
- **Operations**: [Name/Role]
- **Security**: [Name/Role] (if applicable)
- **Tester**: [Name/Role]
- **Documentation**: [Name/Role]

**Resource Provisioning**:
- [ ] Compute: [Allocation required]
- [ ] Memory: [Allocation required]
- [ ] Storage: [Allocation required]
- [ ] Network: [Allocation required]

**Timeline Estimation**:
- Planning: [Days]
- Pre-Deployment: [Days]
- Deployment: [Hours]
- Validation: [Hours]
- Post-Deployment: [Days]
- Total: [Timeline]

### Dependency Verification

**Upstream Dependencies**:
- [ ] [Agent 1] - Verify operational status
  - Status check: `[Command]`
  - Expected: [Status]
  - Verification: [How confirmed]

- [ ] [Agent 2] - Verify version compatibility
  - Version check: `[Command]`
  - Expected: [Version]
  - Verification: [How confirmed]

**Downstream Dependencies**:
- [ ] [Agent 3] - Verify can accept new data source
  - Readiness check: [Procedure]
  - Expected: [Status]

### Team Briefing

**Briefing Meeting**:
- [ ] Date/Time: [Scheduled]
- [ ] Attendees: [Who must attend]
- [ ] Duration: [Estimate: 30-60 min]
- [ ] Topics Covered:
  - [ ] Agent overview
  - [ ] Integration points
  - [ ] Deployment timeline
  - [ ] Rollback procedure
  - [ ] Escalation path
  - [ ] Questions & concerns

---

## Phase 2: Pre-Deployment

### Environment Preparation

**Compute Environment**:
- [ ] Node allocated: [Hostname/IP]
- [ ] Resource quotas set: [CPU/Memory/Disk]
- [ ] Network configured: [NICs, IPs, routes]
- [ ] Storage configured: [Mount points, permissions]

**Staging Validation**:
- [ ] Deploy to staging first (if applicable)
- [ ] Verify configuration in staging
- [ ] Verify integrations in staging
- [ ] Performance test in staging
- [ ] Security test in staging
- [ ] Get sign-off before production

### Configuration Setup

**Configuration Files**:
- [ ] Configuration templates prepared
  - Location: [Path]
  - Version: [Version]
  - Review status: ✅ Reviewed

- [ ] Environment-specific configs generated
  - [Environment 1] config: [Location]
  - [Environment 2] config: [Location]
  - Review status: ✅ Reviewed

- [ ] Secrets provisioned securely
  - Secrets provider: [System]
  - Secret names: [List]
  - Verification: [How confirmed]

**Configuration Validation**:
- [ ] Syntax validation passed: `[Command]`
- [ ] Schema validation passed: `[Command]`
- [ ] Security review passed: [Who reviewed]
- [ ] Performance review passed: [Who reviewed]

### Backup Creation

**Backup Upstream Dependencies**:
- [ ] [Upstream Agent 1] backup created
  - Backup command: `[Command]`
  - Backup location: [Path]
  - Verification: `[Verification command]`

- [ ] [Upstream Agent 2] backup created
  - Backup command: `[Command]`
  - Backup location: [Path]
  - Verification: `[Verification command]`

**Backup System State**:
- [ ] Current configuration backed up
- [ ] Current database backed up (if applicable)
- [ ] Current logs backed up
- [ ] Recovery tested: [Date]
- [ ] Retention verified: [Retention duration]

### Rollback Plan

**Rollback Procedure Document**:
- [ ] Location: [Path to runbook]
- [ ] Steps documented: [Number]
- [ ] Estimated rollback time: [Duration]
- [ ] Data loss if rollback: [Amount/type]

**Rollback Validation**:
- [ ] Rollback procedure reviewed: [Who reviewed]
- [ ] Rollback command tested: ✅ Works / ⚠️ [Issue]
- [ ] Recovery plan verified: ✅ Verified
- [ ] Team trained on rollback: ✅ Trained

---

## Phase 3: Deployment

### Pre-Deployment Checks

**30 minutes before deployment**:
- [ ] All downstream dependents notified
- [ ] Maintenance window announced
- [ ] Support team briefed
- [ ] Escalation contacts confirmed
- [ ] Monitoring dashboards prepared
- [ ] Alert silencing configured (if needed)

**Immediate pre-deployment** (5 minutes):
- [ ] Upstream dependencies verified running
- [ ] Staging deployment verified
- [ ] Team in war room / communications channel
- [ ] Rollback plan reviewed with team
- [ ] Deployment log started: [Location]

### Agent Installation

**Installation Method**:
- [ ] Method: [Container/Package/Source]
- [ ] Source: [Image/Repository/Location]
- [ ] Version: [Version to deploy]

**Installation Steps**:

```bash
# Step 1: Prepare installation directory
mkdir -p /opt/agents/[agent-name]
cd /opt/agents/[agent-name]

# Step 2: Download/pull agent
[Installation command]

# Step 3: Extract/prepare files
[Extraction command]

# Step 4: Verify installation
[Verification command]
```

**Installation Verification**:
- [ ] Files in place: `ls -la [directory]`
- [ ] Permissions correct: `stat [directory]`
- [ ] Checksums verified: `sha256sum -c checksums.txt`
- [ ] Dependencies present: `[Dependency check command]`

### Configuration Deployment

**Copy Configuration Files**:
- [ ] Copy config file: `cp [source] [dest]`
- [ ] Set permissions: `chmod [mode] [file]`
- [ ] Verify deployment: `cat [file] | head -20`
- [ ] Validate config: `[Validation command]`

**Set Environment Variables**:
```bash
# Method 1: System environment
export AGENT_NAME=[value]
export AGENT_CONFIG=[path]
export AGENT_LOG_LEVEL=[level]

# Method 2: Configuration file
# (Add to /etc/profile.d/[agent-name].sh)

# Method 3: Container environment
# (Add to docker-compose.yml or similar)
```

**Initialize Data Structures** (if needed):
- [ ] Database migrations run: `[Command]`
- [ ] Initial data loaded: `[Command]`
- [ ] Seed data verified: `[Verification command]`

### Service Startup

**Start the Service**:

**Option 1: Systemd**
```bash
systemctl start [agent-name]
systemctl enable [agent-name]
systemctl status [agent-name]
```

**Option 2: Docker**
```bash
docker-compose -f docker-compose.yml up -d [service-name]
docker ps -a | grep [service-name]
docker logs -f [container-name]
```

**Option 3: Manual**
```bash
cd /opt/agents/[agent-name]
./start.sh
```

**Startup Verification**:
- [ ] Service started successfully: `[Status command]`
- [ ] Service listening on expected port: `netstat -tlnp | grep [port]`
- [ ] No errors in startup logs: `tail -20 [log-file]`
- [ ] Service responsive: `curl -s http://[endpoint]/health`

### Initial Health Checks

**Health Check Procedure**:
- [ ] Service process running: `ps aux | grep [process-name]`
- [ ] Port open and listening: `nc -zv [host] [port]`
- [ ] Health endpoint responsive: `curl http://[endpoint]/health`
- [ ] Startup logs reviewed: No ERROR entries
- [ ] Resource utilization normal: `top -b -n 1 | head -20`

**Expected States**:
- Service state: Running
- HTTP status: 200 OK
- Health status: Healthy
- CPU usage: < [threshold]%
- Memory usage: < [threshold]MB
- Disk usage: No excessive writes

### Data Flow Verification

**Upstream Data Reception**:
- [ ] [Upstream Agent 1] data flowing in
  - Check: `[Verification command]`
  - Expected: [Data sample]
  - Timestamp: [Recent/stale]

- [ ] [Upstream Agent 2] data flowing in
  - Check: [Verification command]
  - Expected: [Data sample]
  - Timestamp: [Recent/stale]

**Downstream Data Transmission**:
- [ ] [Downstream Agent 1] receiving data
  - Check: Verify at consumer side
  - Expected: [Data format]
  - Latency: [Expected delay]

- [ ] [Downstream Agent 2] receiving data
  - Check: Verify at consumer side
  - Expected: [Data format]
  - Latency: [Expected delay]

**No Data Loss**:
- [ ] Count upstream data: [Count]
- [ ] Count downstream data: [Count]
- [ ] Counts match: ✅ Yes / ❌ No ([Difference])
- [ ] Resolution: [If difference, what was done]

---

## Phase 4: Validation

### Run Validation Checklist

**Validation Checklist**:
- [ ] Use: [Agent Name] Validation Checklist
- [ ] Location: [Path to checklist]
- [ ] Scope: [Items to validate]
- [ ] Tester: [Who ran tests]
- [ ] Date: [YYYY-MM-DD]
- [ ] Time: [Duration]
- [ ] Result: ✅ All Passed / 🟡 [N] Failed / ❌ Critical failures

**Failed Items**:
| Item | Issue | Severity | Resolution | Status |
|------|-------|----------|------------|--------|
| [Item 1] | [Problem] | [SEV] | [Action] | ✅/🟡/❌ |

### Performance Testing

**Load Testing**:
- [ ] Test tool: [Tool name]
- [ ] Test load: [Concurrent connections/RPS]
- [ ] Test duration: [Time]
- [ ] Measured latency: [p50/p95/p99 ms]
- [ ] Success rate: [%]
- [ ] Errors: [Number/type]

**Performance Targets**:
| Metric | Target | Measured | Status |
|--------|--------|----------|--------|
| Latency (p50) | [ms] | [ms] | ✅/❌ |
| Latency (p95) | [ms] | [ms] | ✅/❌ |
| Throughput | [ops/sec] | [ops/sec] | ✅/❌ |
| Error rate | < [%] | [%] | ✅/❌ |

### Escalation Testing

**Escalation Path Verification**:
- [ ] Alert triggered correctly: ✅ Yes / ❌ No
- [ ] Notification sent: ✅ Yes / ❌ No
- [ ] Alert routing correct: ✅ Yes / ❌ No
- [ ] Escalation time acceptable: [Time]

### Security Audit

**Security Checklist**:
- [ ] Authentication working: ✅ Yes
- [ ] Authorization enforced: ✅ Yes
- [ ] Encryption in transit: ✅ Yes (TLS [version])
- [ ] Encryption at rest: ✅ Yes ([Cipher])
- [ ] No hardcoded secrets: ✅ Verified
- [ ] Access logs present: ✅ Yes
- [ ] Security scan passed: ✅ Passed (0 issues)

### Sign-Off

**Acceptance Criteria**:
- [x] Validation checklist: ✅ Passed
- [x] Performance targets: ✅ Met
- [x] Security audit: ✅ Passed
- [x] Escalation testing: ✅ Passed
- [x] Team sign-off: ✅ [Names]

**Sign-Off**:
- Approver: [Name/Title]
- Date: [YYYY-MM-DD]
- Status: ✅ APPROVED / 🟡 APPROVED WITH CONDITIONS / ❌ REJECTED

---

## Phase 5: Post-Deployment

### Monitoring Setup

**Monitoring Configuration**:
- [ ] Prometheus scrape config added: [File]
- [ ] Alerting rules created: [Number] rules
- [ ] Dashboard created: [Link]
- [ ] Log aggregation configured: [System]

**Verification**:
- [ ] Metrics appearing in Prometheus: ✅ Yes ([Sample query])
- [ ] Dashboard displaying data: ✅ Yes
- [ ] Logs appearing in aggregator: ✅ Yes ([Sample query])

### Alert Testing

**Test Alert Trigger**:
- [ ] Trigger alert condition: [How to trigger]
- [ ] Alert fires: ✅ Yes ([Time to fire])
- [ ] Notification sent: ✅ Yes ([Channel])
- [ ] Alert threshold reasonable: ✅ Yes

**Alert Tuning**:
- [ ] False positive rate acceptable: ✅ Yes
- [ ] Alert description clear: ✅ Yes
- [ ] Runbook referenced: ✅ Yes
- [ ] Escalation path clear: ✅ Yes

### Documentation Update

**Update Agent Documentation**:
- [ ] Skills document final version: [Version]
- [ ] Deployment runbook created: [Path]
- [ ] Troubleshooting guide created: [Path]
- [ ] Architecture diagram updated: [Location]

**Update Master Indices**:
- [ ] AGENT_ECOSYSTEM_INDEX.md: Status → 🟢 Deployed
- [ ] Phase index (if applicable): Status → Complete
- [ ] Domain index: Links updated
- [ ] Coordination docs: Updated with production details

**Other Documentation**:
- [ ] Architecture documentation: Updated
- [ ] Network diagram: Updated (if applicable)
- [ ] Data flow diagram: Updated (if applicable)
- [ ] Runbook library: Agent runbook added

### Team Training

**Training Session**:
- [ ] Scheduled: [Date/Time]
- [ ] Attendees: [Names/Roles]
- [ ] Duration: [Time]
- [ ] Topics covered:
  - [ ] Agent overview
  - [ ] How to monitor
  - [ ] Common issues & solutions
  - [ ] Escalation procedures
  - [ ] Hands-on demo

**Training Verification**:
- [ ] Attendees can describe agent purpose: ✅ Yes
- [ ] Attendees can monitor agent: ✅ Yes
- [ ] Attendees can troubleshoot: ✅ Yes
- [ ] Attendees can escalate: ✅ Yes

### Production Cutover

**Cutover Checklist**:
- [ ] All validation passed
- [ ] All documentation updated
- [ ] All monitoring active
- [ ] All alerts tested
- [ ] All team trained
- [ ] Stakeholders approved
- [ ] Maintenance window closed

**Cutover Steps**:
1. [ ] Update production configuration (if needed)
2. [ ] Announce service fully operational
3. [ ] Update status page
4. [ ] Begin normal incident support
5. [ ] Close deployment ticket

---

## Phase 6: Stabilization

### Monitor for Issues

**Early Monitoring** (First 24 hours):
- [ ] Check every hour:
  - Service running: ✅ Yes
  - Latency normal: ✅ Yes
  - Error rate low: ✅ Yes
  - Resource usage normal: ✅ Yes
  - Data flowing: ✅ Yes

**Ongoing Monitoring** (First week):
- [ ] Check every shift
- [ ] Issues logged: [Tracking system]
- [ ] Known issues: [List]
- [ ] Hotfixes deployed: [List]

### Performance Baseline

**Establish Baseline Metrics**:
- [ ] Latency percentiles established:
  - p50: [Value]
  - p95: [Value]
  - p99: [Value]

- [ ] Throughput baseline: [ops/sec]
- [ ] Resource baselines:
  - CPU: [%]
  - Memory: [MB]
  - Disk I/O: [MB/s]

**Record Baseline**:
- [ ] Recorded in: [System]
- [ ] Used for: [Alerting thresholds, capacity planning]
- [ ] Review frequency: [Monthly/Quarterly]

### Optimize if Needed

**Performance Issues**:
- [ ] Issue identified: [Description]
- [ ] Root cause: [Analysis]
- [ ] Optimization applied: [Change]
- [ ] Improvement verified: [Results]

**Cost Optimization**:
- [ ] Resource utilization reviewed
- [ ] Over-provisioning identified: [Items]
- [ ] Optimization applied: [Changes]
- [ ] Savings verified: [Amount]

### Close Deployment

**Deployment Closeout**:
- [ ] Deployment ticket closed: [Ticket ID]
- [ ] Deployment retrospective held: [Date]
- [ ] Issues documented: [Issues found]
- [ ] Improvements for next deployment: [List]
- [ ] Final sign-off: [Name/Date]

**Handoff to Operations**:
- [ ] Agent transferred to ops ownership
- [ ] Support procedures established
- [ ] On-call contacts updated
- [ ] Escalation path confirmed
- [ ] Incident response plan ready

---

## Deployment Checklist

### Pre-Deployment (Phase 1-2)
- [ ] Requirements reviewed
- [ ] Team assigned
- [ ] Dependencies verified
- [ ] Environment prepared
- [ ] Configuration validated
- [ ] Backups created
- [ ] Rollback plan ready

### Deployment (Phase 3)
- [ ] Pre-checks passed
- [ ] Agent installed
- [ ] Configuration deployed
- [ ] Service started
- [ ] Health checks passed
- [ ] Data flow verified

### Post-Deployment (Phase 4-6)
- [ ] Validation passed
- [ ] Performance verified
- [ ] Security verified
- [ ] Monitoring active
- [ ] Alerts tested
- [ ] Documentation updated
- [ ] Team trained
- [ ] Production cutover complete
- [ ] Stabilization verified
- [ ] Deployment closed

---

## Rollback Decision Tree

```
Deployment Status:
├─ Issue Found During Installation?
│  ├─ YES → Rollback immediately (Phase 3)
│  └─ NO → Continue
│
├─ Issue Found During Validation?
│  ├─ Critical → Rollback immediately
│  ├─ High → Escalate for decision
│  ├─ Medium → Create fix ticket, monitor closely
│  └─ Low → Document, continue
│
├─ Issue Found After Cutover?
│  ├─ Critical (SLA breach) → Rollback immediately
│  ├─ High → Escalate for decision
│  ├─ Medium → Create fix, deploy in next window
│  └─ Low → Document, schedule fix
│
└─ Escalation Path:
   ├─ First: [On-call engineer]
   ├─ Second: [Team lead]
   └─ Final: [Engineering manager]
```

---

## Quick Reference

### Common Commands

```bash
# Check deployment status
systemctl status [agent-name]
docker ps -a | grep [agent-name]

# View logs
journalctl -u [agent-name] -f
docker logs -f [container-name]

# Restart agent
systemctl restart [agent-name]
docker-compose restart [service-name]

# Rollback (if needed)
systemctl stop [agent-name]
[Restore from backup]
systemctl start [agent-name]
```

### Critical Contacts

| Role | Name | Phone | Email |
|------|------|-------|-------|
| On-Call | [Name] | [Phone] | [Email] |
| Team Lead | [Name] | [Phone] | [Email] |
| Manager | [Name] | [Phone] | [Email] |

---

## Documentation References

- **Agent Skills Template**: `templates/AGENT_SKILLS_TEMPLATE.md`
- **Validation Checklist**: `templates/VALIDATION_CHECKLIST_TEMPLATE.md`
- **Coordination Template**: `templates/COORDINATION_TEMPLATE.md`
- **Agent Roadmap**: `AGENT_ROADMAP.md`
- **Ecosystem Index**: `AGENT_ECOSYSTEM_INDEX.md`

---

**Last Updated**: September 16, 2026  
**Version**: 1.0  
**Owner**: DevOps/Operations Team  
**Review Frequency**: After each deployment, formal review quarterly
