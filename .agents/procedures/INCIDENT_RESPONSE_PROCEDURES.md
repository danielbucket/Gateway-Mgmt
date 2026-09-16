# Incident Response Procedures

This document describes the standardized procedures for responding to incidents in the gateway management system.

---

## Incident Response Overview

```
Detection
  ↓ (Alert triggered)
Classification
  ↓ (Assess severity)
Escalation
  ↓ (Notify team)
Investigation
  ↓ (Understand problem)
Mitigation
  ↓ (Stop the bleeding)
Resolution
  ↓ (Fix the problem)
Communication
  ↓ (Keep stakeholders informed)
Recovery
  ↓ (Restore to normal)
Post-Incident Review
  ↓ (Learn & prevent)
Closure
```

---

## Incident Severity Matrix

### SEV1 - Critical (Immediate Response Required)

**Definition**: Complete service outage affecting all users

**Characteristics**:
- Service completely unavailable
- Data loss occurring
- Security breach in progress
- SLA violations imminent
- All users affected

**Response Time**: <5 minutes to first responder  
**Resolution Time**: <30 minutes target

**Examples**:
- Complete Gateway node failure
- Database cluster down
- Network completely disconnected
- Ransomware/security incident active
- All agents simultaneously failing

**Response**:
1. [ ] Immediately page on-call lead
2. [ ] Establish war room (Slack #incident-response)
3. [ ] Notify stakeholders
4. [ ] Activate disaster recovery plan (if applicable)
5. [ ] Begin investigation immediately

---

### SEV2 - High (Urgent Response Required)

**Definition**: Significant degradation affecting subset of users

**Characteristics**:
- Partial service outage
- Significant performance degradation
- Data loss risk (not occurring)
- Some users unable to work
- Workaround possible

**Response Time**: <15 minutes to first responder  
**Resolution Time**: <2 hours target

**Examples**:
- Single agent failure
- Database performance degradation (>5 sec latency)
- Memory leak causing OutOfMemory errors
- Authentication failures for subset of users
- Network latency causing timeouts

**Response**:
1. [ ] Page on-call engineer
2. [ ] Update status page
3. [ ] Begin investigation
4. [ ] Implement workaround if available
5. [ ] Communicate updates every 15 minutes

---

### SEV3 - Medium (Normal Response Time)

**Definition**: Minor issues with workarounds or limited impact

**Characteristics**:
- Specific feature degraded
- Limited user impact (< 5% of user base)
- Workaround available
- No data loss risk
- Users can continue working

**Response Time**: <1 hour  
**Resolution Time**: <4 hours target

**Examples**:
- Single report running slow
- Feature partially working
- Log aggregation delayed
- Metrics delayed by 5-10 minutes
- Minor UI glitch

**Response**:
1. [ ] Create incident ticket
2. [ ] Begin investigation
3. [ ] Document workaround for users
4. [ ] Communicate updates as appropriate

---

### SEV4 - Low (Scheduled Resolution)

**Definition**: Cosmetic issues or future improvements

**Characteristics**:
- No user impact
- Feature request or documentation issue
- Scheduled resolution acceptable
- No urgency

**Response Time**: Next business day  
**Resolution Time**: Scheduled

**Examples**:
- Documentation typo
- Feature request
- Code cleanup
- Performance optimization (non-critical)

**Response**:
1. [ ] Create tracking ticket
2. [ ] Schedule for future sprint
3. [ ] No immediate investigation needed

---

## Incident Response Workflow

### Phase 1: Detection & Alert

**Alert Sources**:
- Prometheus alerting (automated)
- Anomaly detection
- User reports
- Manual observation

**Alert Reception**:
- [ ] Alert received in: [Monitoring system]
- [ ] Escalation email sent: ✅
- [ ] Page sent to on-call: ✅
- [ ] Slack notification: ✅

**Alert Handling**:
```
Is alert legitimate?
├─ YES → Classify severity (go to Phase 2)
└─ NO → Silence alert and investigate root cause
```

---

### Phase 2: Classification & Escalation

**Triage Questions**:

1. **What component is affected?**
   - Single agent: SEV2-3
   - Multiple agents: SEV1-2
   - Infrastructure: SEV1

2. **How many users affected?**
   - All users: SEV1
   - Subset (> 10%): SEV2
   - Subset (1-10%): SEV3
   - < 1%: SEV4

3. **Is data at risk?**
   - Data loss occurring: SEV1
   - Data loss possible: SEV2
   - No data risk: SEV3-4

4. **Is service fully unavailable?**
   - Yes: SEV1
   - Degraded: SEV2
   - Minor: SEV3-4

**Classification Matrix**:

| Availability | Data Risk | User Impact | Severity |
|---|---|---|---|
| Complete outage | Yes | All | **SEV1** |
| Complete outage | No | All | **SEV1** |
| Degraded | Yes | Many | **SEV2** |
| Degraded | No | Some | **SEV2** |
| Degraded | No | Few | **SEV3** |
| Minor | No | Very few | **SEV3** |
| None | No | None | **SEV4** |

**Assign Severity**:
- SEV1 → Immediate escalation to on-call lead
- SEV2 → Page on-call engineer
- SEV3 → Create ticket, notify team
- SEV4 → Log ticket for future handling

**Escalation Chain** (if initial responder cannot resolve):

```
First Responder (on-call engineer)
  ↓ (15 min if unresolved)
Team Lead
  ↓ (30 min if unresolved)
Engineering Manager
  ↓ (1 hour if unresolved - decision to escalate/rollback)
VP Engineering / CTO
```

---

### Phase 3: War Room Setup

**For SEV1 & SEV2 Incidents**:

**War Room Channel**: Slack `#incident-response` (or Teams channel)

**Required Attendees**:
- [ ] Incident Commander (leads the response)
- [ ] Primary Responder (investigating)
- [ ] Subject Matter Expert (if not primary)
- [ ] Communication Lead (updating status)
- [ ] Manager/Lead (decisions)

**War Room Setup**:
```
Incident Commander: [Name]
Start Time: [YYYY-MM-DD HH:MM:SS UTC]
Severity: SEV[1-2]
Affected Service: [Service name]
Estimated Impact: [X users affected]

Status Timeline:
[HH:MM] Initial alert received
[HH:MM] War room established
[HH:MM] Investigation started
```

**Communication Cadence**:
- SEV1: Update every 2-3 minutes
- SEV2: Update every 5-10 minutes
- SEV3+: Update every 15-30 minutes

---

### Phase 4: Investigation

**Investigation Checklist**:

**Step 1: Gather Context**
- [ ] Review alert details
- [ ] Check recent changes (deployments, config)
- [ ] Review error logs
- [ ] Check performance metrics
- [ ] Verify downstream impacts
- [ ] Check upstream dependencies

**Step 2: Identify Affected Component**
- [ ] Agent: [Agent name]
- [ ] System: [System name]
- [ ] Infrastructure: [Component]
- [ ] External dependency: [Service]

**Step 3: Initial Diagnosis**
- [ ] Service running? `systemctl status [service]`
- [ ] Disk space? `df -h`
- [ ] Memory? `free -h`
- [ ] CPU? `top -b -n 1`
- [ ] Network connectivity? `ping [host]`
- [ ] Port open? `netstat -tlnp | grep [port]`

**Step 4: Root Cause Analysis**

**Check Recent Changes**:
- [ ] Recent deployment: [What changed]
- [ ] Recent config change: [What changed]
- [ ] Recent scaling event: [What happened]
- [ ] Upstream dependency change: [What changed]

**Common Root Causes**:
1. **Memory/Resource Issue**
   - Check: `free -h`, `df -h`
   - Solution: Increase resources, kill memory leaks, cleanup

2. **Connectivity Issue**
   - Check: `ping`, `netstat`, `curl`
   - Solution: Verify firewall, restart services, check DNS

3. **Configuration Issue**
   - Check: Config file syntax, permission
   - Solution: Fix config, restart service, test

4. **Dependency Issue**
   - Check: Upstream service status
   - Solution: Escalate to upstream team, use fallback

5. **Bug/Logic Error**
   - Check: Logs, metrics, code
   - Solution: Hotfix, rollback deployment

6. **Security Issue**
   - Check: Access logs, firewall, intrusion detection
   - Solution: Block attacker, enable security controls

**Document Findings**:
- Root cause: [Description]
- Contributing factors: [List]
- When problem started: [Time]
- Estimated duration: [Time]

---

### Phase 5: Mitigation (Stop the Bleeding)

**Mitigation vs. Resolution**:
- **Mitigation**: Temporary fix to stop impact (e.g., restart service)
- **Resolution**: Permanent fix to underlying issue (e.g., fix bug)

**Fast Mitigation Options** (in order of speed):

**Option 1: Restart Service** (< 1 min)
```bash
systemctl restart [service-name]
# or
docker-compose restart [service-name]

# Monitor for recovery
systemctl status [service-name]
```

**Option 2: Scale/Failover** (< 5 min)
```bash
# Failover to backup instance
[Failover procedure]

# Verify functioning
[Health check]
```

**Option 3: Enable Workaround** (< 10 min)
```bash
# Disable feature
# Enable fallback
# Redirect traffic
[Specific workaround steps]
```

**Option 4: Rollback** (< 15 min)
```bash
# Stop current version
systemctl stop [service]

# Restore previous version
[Restore procedure]

# Start and verify
systemctl start [service]
```

**Mitigation Verification**:
- [ ] Service now responding: ✅ Yes
- [ ] Users able to work: ✅ Yes
- [ ] Data integrity verified: ✅ Yes
- [ ] No additional errors: ✅ Yes

**Update War Room**:
```
[HH:MM] Mitigation applied: [Action taken]
[HH:MM] Service status: Recovering / Recovered
[HH:MM] Users affected: Resolving
```

---

### Phase 6: Investigation Continues (During Mitigation)

**While Service Recovered, Root Cause Analysis**:
- [ ] Reproduce issue in test environment
- [ ] Identify exact code/config causing problem
- [ ] Prepare permanent fix
- [ ] Test fix thoroughly
- [ ] Plan deployment

**Document Investigation**:
```
Timeline:
[HH:MM] Alert triggered
[HH:MM] War room opened
[HH:MM] Root cause identified
[HH:MM] Mitigation applied
[HH:MM] Investigation continued
[HH:MM] Fix prepared

Root Cause:
[Description]

Contributing Factors:
[List]

Permanent Fix:
[Description]

Prevention:
[How to prevent recurring]
```

---

### Phase 7: Resolution

**Deploy Permanent Fix**:

**Option 1: Hotfix Deployment** (if urgent)
- [ ] Code reviewed: ✅ [Reviewer]
- [ ] Tests passed: ✅ [Tests run]
- [ ] Change approved: ✅ [Approver]
- [ ] Deployed to staging: ✅ Verified
- [ ] Deployed to production: ✅ Monitoring

**Option 2: Scheduled Fix** (if non-urgent)
- [ ] Create ticket for fix
- [ ] Schedule for next sprint
- [ ] Monitor for recurrence
- [ ] Plan deployment

**Verification After Resolution**:
- [ ] Service stable: ✅ Yes (> 30 min)
- [ ] Metrics normal: ✅ Yes
- [ ] No errors in logs: ✅ Yes
- [ ] Users reporting normal: ✅ Yes

**Update War Room**:
```
[HH:MM] Permanent fix deployed
[HH:MM] Service stable
[HH:MM] Incident resolved
[HH:MM] Post-incident review scheduled
```

---

### Phase 8: Communication

**Initial Notification** (immediately upon detection):
```
INCIDENT ALERT: [Service] experiencing issues
Severity: SEV[1-4]
Start Time: [Time]
Impact: [X users affected]
Status: Investigating
Next Update: [Time]
```

**Ongoing Updates** (every 5-10 min for SEV1-2):
```
UPDATE [N]: [Time]
Status: [Investigating / Mitigating / Recovering / Resolved]
Progress: [What's been done]
Next Steps: [What's planned]
Next Update: [Time]
```

**Resolution Notification**:
```
RESOLVED: [Service] issue resolved
Start Time: [Time]
End Time: [Time]
Duration: [Minutes]
Impact: [X users affected for Y minutes]
Root Cause: [Brief description]
Action Plan: Post-incident review scheduled
```

**Channels to Notify**:
- Slack: #incident-response (all)
- Slack: #[team-name] (relevant team)
- Email: Stakeholders (managers, customers if applicable)
- Status page: Public if customer-impacting
- Escalation contacts: Per severity level

---

### Phase 9: Recovery & Monitoring

**Enhanced Monitoring Post-Incident**:
- [ ] Increased alerting sensitivity: [Thresholds]
- [ ] Frequent health checks: [Interval]
- [ ] Log tailing: `tail -f [log-file]`
- [ ] Metric dashboards: Open for observation
- [ ] On-call focus: Extra attention for [Duration]

**Recovery Procedure** (if applicable):
- [ ] Restart dependent services: [Services]
- [ ] Clear cache/queues: [Items]
- [ ] Verify data consistency: [Checks]
- [ ] Reindex if needed: [Procedure]

**Monitoring Duration**:
- SEV1: 24 hours of enhanced monitoring
- SEV2: 12 hours of enhanced monitoring
- SEV3+: 4 hours of normal monitoring
- Then: Return to baseline

**Success Criteria**:
- ✅ Service stable (no recurring issues)
- ✅ Performance baseline restored
- ✅ User reports of normal operation
- ✅ All health checks green

---

### Phase 10: Post-Incident Review

**Timing**: Within 2 business days

**Attendees**:
- [ ] Incident Commander
- [ ] Primary Responder
- [ ] Subject Matter Experts
- [ ] Team Lead
- [ ] Manager

**Review Agenda**:

1. **What Happened?**
   - Timeline of events
   - Actions taken
   - Outcomes

2. **Why Did It Happen?**
   - Root cause
   - Contributing factors
   - Systemic issues

3. **What Should We Do Differently?**
   - Process improvements
   - Technical improvements
   - Monitoring improvements
   - Documentation improvements

4. **Action Items**
   - [ ] Action 1: [Owner, Due Date]
   - [ ] Action 2: [Owner, Due Date]
   - [ ] Action 3: [Owner, Due Date]

**Review Document**:
```markdown
# Post-Incident Review: [Service] [Date]

## Incident Summary
- Severity: SEV[1-4]
- Duration: [Minutes]
- Users Affected: [Count]
- Services Down: [List]

## Timeline
[HH:MM] Event
[HH:MM] Event
[HH:MM] Event

## Root Cause
[Description]

## Contributing Factors
- [Factor 1]
- [Factor 2]

## Actions Taken
- [Action 1] at [Time]
- [Action 2] at [Time]

## What Went Well
- [Good response point 1]
- [Good response point 2]

## What We Should Improve
- [Improvement 1]
- [Improvement 2]

## Action Items
- [Item] - [Owner] - [Due Date]

## Prevention
[How to prevent recurring]
```

**Distribution**:
- [ ] Team review meeting held
- [ ] Document shared with team
- [ ] Document archived
- [ ] Action items tracked
- [ ] Follow-up on action items (weekly)

---

## Incident Response Contacts

### On-Call Rotation

| Week | Primary (Engineer) | Secondary (Lead) | Manager |
|------|---|---|---|
| Week 1 | [Name] | [Name] | [Name] |
| Week 2 | [Name] | [Name] | [Name] |

**Contact Methods**:
- Phone: [Phone numbers]
- Slack: @[Handles]
- Email: [Emails]

**On-Call Handoff**:
- Every [Day] at [Time]
- Handoff meeting: [Duration]
- Context shared: [How]

### Escalation Contacts

| Role | Name | Title | Phone | Email |
|------|------|-------|-------|-------|
| Engineering Lead | [Name] | [Title] | [Phone] | [Email] |
| Team Lead | [Name] | [Title] | [Phone] | [Email] |
| Manager | [Name] | [Title] | [Phone] | [Email] |
| CTO | [Name] | [Title] | [Phone] | [Email] |

---

## Incident Response Runbooks

### Runbook: [Service] Agent Down

**Symptoms**:
- Service not responding
- Health checks failing
- Metrics missing
- Alerts firing

**Quick Fix** (< 5 min):
```bash
# 1. Check service status
systemctl status [service]

# 2. Restart if down
systemctl restart [service]

# 3. Verify running
systemctl status [service]
curl http://[endpoint]/health
```

**If Not Fixed** (escalate to SEV2):
- [ ] Check logs: `journalctl -u [service] -n 50`
- [ ] Check resources: `free -h && df -h && top -b -n 1`
- [ ] Check ports: `netstat -tlnp | grep [port]`
- [ ] Escalate to team lead

### Runbook: Database Connection Pool Exhausted

**Symptoms**:
- "Connection pool exhausted" errors
- Database latency increases
- Application timeouts

**Quick Fix** (< 10 min):
```bash
# 1. Check connection count
psql -U [user] -d [db] -c "SELECT count(*) FROM pg_stat_activity;"

# 2. Identify long-running queries
psql -U [user] -d [db] -c "SELECT * FROM pg_stat_activity WHERE state != 'idle';"

# 3. Kill long-running queries if safe
psql -U [user] -d [db] -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE duration > interval '30 minutes';"

# 4. Restart connection-consuming service
systemctl restart [service-with-leak]
```

**Monitoring**:
- [ ] Connection count decreasing
- [ ] Application recovering
- [ ] Latency returning to normal

---

## Incident Statistics & Trending

**Metrics to Track**:
- Mean Time to Detection (MTTD): [Minutes]
- Mean Time to Response (MTTR): [Minutes]
- Mean Time to Recovery (MTTR): [Minutes]
- Incident count by severity: [Numbers]
- Most common causes: [List]

**Review Quarterly**:
- [ ] Trending: Improving or worsening?
- [ ] Root causes: Recurring patterns?
- [ ] Prevention: Are fixes preventing recurrence?
- [ ] Processes: Need improvement?

---

**Last Updated**: September 16, 2026  
**Version**: 1.0  
**Owner**: Operations / Incident Response Team  
**Review Frequency**: After each incident, formal review quarterly
