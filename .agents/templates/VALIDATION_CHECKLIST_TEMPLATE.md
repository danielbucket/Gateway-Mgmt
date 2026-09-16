# Validation Checklist Template

This template defines the standard format for validation checklists used to verify agent implementation and operational correctness.

---

## File Naming Convention

Format: `[AGENT_NAME]_VALIDATION_CHECKLIST.md` or included in `[AGENT_NAME]_AGENT_SKILLS.md`

Examples:
- `DOCKER_AGENT_VALIDATION_CHECKLIST.md`
- `LOGGING_AGENT_VALIDATION_CHECKLIST.md`
- Or as a section in the skills file

---

## Validation Philosophy

✅ **Validation ensures**:
- Every agent skill is implemented correctly
- All integration points work
- Constraints are met
- Operations are sound
- Disaster recovery works
- Security controls are in place

---

## Template Structure

```markdown
# [Agent Name] - Validation Checklist

**Status**: 🟢 All Passed / 🟡 In Progress / 🔴 Failed  
**Last Validation**: [YYYY-MM-DD]  
**Validated By**: [Name/Role]  
**Next Review**: [YYYY-MM-DD]

---

## Pre-Deployment Validation

### Installation & Configuration

- [ ] **INST-001**: [Agent] installed successfully
  - **Verification**: [How to verify]
  - **Expected Result**: [What success looks like]

- [ ] **INST-002**: Configuration files created
  - **Verification**: [How to verify]
  - **Expected Result**: [What success looks like]

- [ ] **INST-003**: Required dependencies installed
  - **Verification**: Check: `[command]`
  - **Expected Result**: All dependencies present

- [ ] **INST-004**: Environment variables configured
  - **Verification**: `[command to verify]`
  - **Expected Result**: [Expected values shown]

### Health Checks

- [ ] **HEALTH-001**: [Agent] process/service running
  - **Verification**: `[command]`
  - **Expected Result**: [Service state]

- [ ] **HEALTH-002**: [Agent] responding to API calls
  - **Verification**: `[curl/API call]`
  - **Expected Result**: [Success response]

- [ ] **HEALTH-003**: Logs show no critical errors
  - **Verification**: `[log inspection command]`
  - **Expected Result**: [No ERROR entries in last N minutes]

### Connectivity

- [ ] **CONN-001**: Can reach upstream dependencies
  - **Dependency**: [Agent A]
  - **Verification**: `[connectivity test]`
  - **Expected Result**: [Connection successful]

- [ ] **CONN-002**: Can reach downstream dependents
  - **Dependent**: [Agent B]
  - **Verification**: `[connectivity test]`
  - **Expected Result**: [Connection successful]

- [ ] **CONN-003**: Network ports open & responsive
  - **Ports**: [List ports]
  - **Verification**: `[port scan command]`
  - **Expected Result**: [All ports open/listening]

### Resource Allocation

- [ ] **RESOURCE-001**: CPU allocation adequate
  - **Target**: [X CPU cores]
  - **Verification**: `[monitoring command]`
  - **Expected Result**: [CPU util < threshold]

- [ ] **RESOURCE-002**: Memory allocation adequate
  - **Target**: [X GB RAM]
  - **Verification**: `[monitoring command]`
  - **Expected Result**: [Memory util < threshold]

- [ ] **RESOURCE-003**: Disk space adequate
  - **Target**: [X GB free]
  - **Verification**: `[disk space command]`
  - **Expected Result**: [X GB+ available]

---

## Skill Validation

### Skill Group 1: [Skill Category - e.g., "Core Operations"]

#### Skill 1: [Skill Name]

- [ ] **SK-001**: [Skill] implemented
  - **Verification**: [How to test]
  - **Expected Result**: [Success criteria]
  - **Acceptance Criteria**:
    - [ ] Function exists
    - [ ] Returns expected output
    - [ ] No errors logged
    - [ ] Performance < [X] seconds

- [ ] **SK-002**: [Skill] error handling working
  - **Verification**: [How to trigger error]
  - **Expected Result**: [Error handled gracefully]
  - **Acceptance Criteria**:
    - [ ] Error caught correctly
    - [ ] Logged appropriately
    - [ ] User-friendly message
    - [ ] No system crash

- [ ] **SK-003**: [Skill] integration with [Agent] working
  - **Dependency**: [Agent name]
  - **Verification**: [Integration test]
  - **Expected Result**: [Successful integration]

#### Skill 2: [Skill Name]

[Similar structure for each skill]

### Skill Group 2: [Skill Category]

[Repeat skill validation structure]

---

## Integration Validation

### Upstream Dependencies

- [ ] **UP-001**: [Upstream Agent A] integration
  - **Dependency**: [What this agent provides]
  - **Test**: [How to test integration]
  - **Success Criteria**: [What confirms it works]
  - **Data Flow**: [What data should flow]
  - **Expected Latency**: [Acceptable delay]

- [ ] **UP-002**: [Upstream Agent B] integration
  - **Dependency**: [What this agent provides]
  - **Test**: [How to test integration]
  - **Success Criteria**: [What confirms it works]

### Downstream Dependencies

- [ ] **DOWN-001**: [Downstream Agent A] can access our data
  - **Consumer**: [Which agent]
  - **Test**: [How to test]
  - **Success Criteria**: [What confirms it works]
  - **Data Format**: [Expected format]

- [ ] **DOWN-002**: [Downstream Agent B] can call our APIs
  - **Consumer**: [Which agent]
  - **Test**: [How to test]
  - **Success Criteria**: [What confirms it works]

### Cross-Domain Integrations

- [ ] **CROSS-001**: [Domain 1] integration working
  - **Verification**: [Test procedure]
  - **Expected Result**: [Success state]

- [ ] **CROSS-002**: [Domain 2] integration working
  - **Verification**: [Test procedure]
  - **Expected Result**: [Success state]

---

## Operational Validation

### Startup & Shutdown

- [ ] **OP-STARTUP-001**: Normal startup successful
  - **Procedure**: [Steps]
  - **Verification**: [What to check]
  - **Expected**: [Service running, logs clean]
  - **Time to Ready**: [Target seconds]

- [ ] **OP-STARTUP-002**: Startup recovery after crash
  - **Procedure**: Kill process & wait for restart
  - **Verification**: Service running within [X] seconds
  - **Expected**: Automatic restart & recovery

- [ ] **OP-SHUTDOWN-001**: Clean shutdown successful
  - **Procedure**: [Shutdown command]
  - **Verification**: Process stopped cleanly
  - **Expected**: No error logs, resources released

- [ ] **OP-SHUTDOWN-002**: In-flight data protected during shutdown
  - **Procedure**: Stop during active operation
  - **Verification**: No data loss
  - **Expected**: Operations complete/rollback correctly

### Performance

- [ ] **PERF-001**: Meets performance SLA
  - **SLA**: [Target response time]
  - **Test**: [How to measure]
  - **Result**: [Measured time]
  - **Pass Criteria**: [Must be < X ms]

- [ ] **PERF-002**: No memory leaks under load
  - **Test Duration**: [How long test runs]
  - **Load**: [Requests/minute]
  - **Verification**: Memory usage remains stable
  - **Pass Criteria**: < 5% growth over [duration]

- [ ] **PERF-003**: No CPU throttling under peak load
  - **Peak Load**: [Requests/minute]
  - **Verification**: `[monitoring command]`
  - **Pass Criteria**: CPU util < 80%

### Monitoring & Alerting

- [ ] **MON-001**: Prometheus metrics exported
  - **Metric Endpoint**: [URL]
  - **Verification**: `curl [endpoint]`
  - **Expected**: Metrics in Prometheus format

- [ ] **MON-002**: Critical alerts configured
  - **Alert Count**: [Number of SEV1 alerts]
  - **Verification**: Alert rules loaded
  - **Expected**: All [N] critical alerts active

- [ ] **MON-003**: Log aggregation working
  - **Logs Received**: [Logging Agent]
  - **Verification**: Logs searchable in [System]
  - **Expected**: All agent logs present

### Health Monitoring

- [ ] **HLTH-001**: Health check endpoint responsive
  - **Endpoint**: [URL]
  - **Verification**: `curl -s [endpoint] | jq .`
  - **Expected**: `{"status": "healthy"}`

- [ ] **HLTH-002**: Health check detects failures
  - **Test**: Simulate failure
  - **Verification**: Health endpoint returns error
  - **Expected**: Monitoring alerted within [X] seconds

---

## Security Validation

### Authentication & Authorization

- [ ] **SEC-AUTH-001**: Authentication required & enforced
  - **Test**: Try access without credentials
  - **Expected**: Request denied
  - **Verification**: 401/403 error

- [ ] **SEC-AUTH-002**: Credentials validated correctly
  - **Test**: Use valid & invalid credentials
  - **Expected**: Valid: access, Invalid: denied

- [ ] **SEC-AUTH-003**: Session management working
  - **Test**: Session timeout, logout
  - **Expected**: Session properly terminated

- [ ] **SEC-AUTH-004**: Multi-factor authentication (if applicable)
  - **Test**: Attempt bypass
  - **Expected**: Cannot bypass MFA

### Encryption

- [ ] **SEC-ENC-001**: Data encrypted in transit
  - **Test**: Network capture TLS traffic
  - **Expected**: TLS 1.2+ negotiated
  - **Cert**: [Certificate details]

- [ ] **SEC-ENC-002**: Data encrypted at rest
  - **Test**: Inspect stored data
  - **Expected**: Data encrypted
  - **Cipher**: [Encryption algorithm]

- [ ] **SEC-ENC-003**: Certificate validation working
  - **Test**: Try invalid certificate
  - **Expected**: Connection rejected

### Access Control

- [ ] **SEC-AC-001**: RBAC enforced
  - **Test**: User with wrong role tries operation
  - **Expected**: Operation denied
  - **Verification**: Audit log shows denial

- [ ] **SEC-AC-002**: Least privilege enforced
  - **Test**: Review assigned permissions
  - **Expected**: Minimal necessary permissions
  - **Audit**: [How verified]

- [ ] **SEC-AC-003**: API key rotation possible
  - **Test**: Rotate API key
  - **Expected**: Old key invalid, new key works
  - **Verification**: [How verified]

### Audit Logging

- [ ] **SEC-LOG-001**: All changes logged
  - **Test**: Make change, check logs
  - **Expected**: Change logged with who/what/when
  - **Format**: [Log format]

- [ ] **SEC-LOG-002**: Logs cannot be modified
  - **Test**: Try to delete logs
  - **Expected**: Deletion denied/detected
  - **Verification**: Write-once or signed logs

- [ ] **SEC-LOG-003**: Sensitive data not logged
  - **Test**: Review logs for passwords/keys
  - **Expected**: No sensitive data present
  - **Audit**: [How verified]

---

## Compliance Validation

### Standards Compliance

- [ ] **COMP-001**: [Standard] compliance verified
  - **Standard**: [e.g., PCI-DSS, HIPAA, SOC2]
  - **Requirement**: [Specific requirement]
  - **Verification**: [How to verify]
  - **Evidence**: [Where documented]

- [ ] **COMP-002**: [Regulation] compliance verified
  - **Regulation**: [e.g., GDPR]
  - **Requirement**: [Specific requirement]
  - **Verification**: [How to verify]
  - **Evidence**: [Where documented]

### Data Handling

- [ ] **COMP-DATA-001**: Data retention policy enforced
  - **Policy**: [Retention duration]
  - **Test**: Verify old data deleted
  - **Expected**: Data aged > [N] days removed

- [ ] **COMP-DATA-002**: Data privacy controls
  - **Control**: [What's protected]
  - **Verification**: [How verified]
  - **Expected**: [Protected correctly]

---

## Disaster Recovery Validation

### Backup & Recovery

- [ ] **DR-BACKUP-001**: Backups created successfully
  - **Frequency**: [Backup cadence]
  - **Verification**: Check backup directory
  - **Expected**: [Number] backups present

- [ ] **DR-BACKUP-002**: Backups verified (not corrupted)
  - **Test**: Restore backup to test system
  - **Expected**: Restore succeeds
  - **Time**: [Restore duration]

- [ ] **DR-BACKUP-003**: Backup retention policy enforced
  - **Policy**: Keep [N] backups / [N] days
  - **Verification**: Check backup count
  - **Expected**: Old backups deleted

### Recovery Procedures

- [ ] **DR-RECOVERY-001**: Recovery procedure documented
  - **Document**: [Path to runbook]
  - **Verification**: Runbook exists & is current
  - **Expected**: Step-by-step recovery process

- [ ] **DR-RECOVERY-002**: Recovery procedure tested
  - **Test Date**: [YYYY-MM-DD]
  - **Tester**: [Name]
  - **Result**: ✅ Successful / ❌ Failed
  - **Recovery Time**: [Actual time]
  - **Data Loss**: [Amount/type]

- [ ] **DR-RECOVERY-003**: Recovery meets RTO target
  - **RTO Target**: [Minutes/hours]
  - **Measured**: [Actual time]
  - **Status**: ✅ Meets / ❌ Exceeds
  - **Action**: [If exceeds target]

- [ ] **DR-RECOVERY-004**: Recovery meets RPO target
  - **RPO Target**: [Maximum data loss]
  - **Measured**: [Actual loss]
  - **Status**: ✅ Meets / ❌ Exceeds

### Failover

- [ ] **DR-FAILOVER-001**: Failover to backup system works
  - **Backup Location**: [Where]
  - **Test Procedure**: [Steps]
  - **Expected**: Services running on backup
  - **Time to Failover**: [Duration]

- [ ] **DR-FAILOVER-002**: Failback to primary works
  - **Test Procedure**: [Steps]
  - **Expected**: Services running on primary
  - **Data Consistency**: ✅ Consistent / ❌ Inconsistent

---

## Constraints Validation

### Operational Constraints

- [ ] **CONST-001**: Maximum concurrent connections not exceeded
  - **Constraint**: [Max value]
  - **Test Load**: [Test value]
  - **Verification**: [How measured]
  - **Result**: ✅ Within limit / ❌ Exceeded

- [ ] **CONST-002**: Maximum throughput not exceeded
  - **Constraint**: [Max value]
  - **Test Load**: [Test value]
  - **Verification**: [How measured]
  - **Result**: ✅ Within limit / ❌ Exceeded

- [ ] **CONST-003**: Memory limit not exceeded
  - **Constraint**: [Max value]
  - **Test Load**: [Test value]
  - **Verification**: `[monitoring command]`
  - **Result**: ✅ Within limit / ❌ Exceeded

### Resource Constraints

- [ ] **CONST-RES-001**: Disk usage within limits
  - **Constraint**: [Max %]
  - **Current**: [Current %]
  - **Verification**: `df -h`
  - **Result**: ✅ Within limit / ❌ Exceeded

- [ ] **CONST-RES-002**: Network bandwidth within limits
  - **Constraint**: [Max Mbps]
  - **Test Load**: [Test value]
  - **Verification**: [How measured]
  - **Result**: ✅ Within limit / ❌ Exceeded

---

## Acceptance Validation

### Overall System

- [ ] **ACCEPT-001**: All validation items passed
  - **Total Items**: [Number]
  - **Passed**: [Number]
  - **Failed**: [Number]
  - **Status**: ✅ All Passed / 🟡 [N] Failed / ❌ Critical failures

- [ ] **ACCEPT-002**: Performance meets SLA
  - **SLA**: [Targets]
  - **Measured**: [Results]
  - **Status**: ✅ Meets / ❌ Exceeds

- [ ] **ACCEPT-003**: Security controls verified
  - **Tests**: [Number] security tests
  - **Passed**: [Number]
  - **Failed**: [Number]
  - **Status**: ✅ Secure / ⚠️ [Issues] / ❌ Critical issues

- [ ] **ACCEPT-004**: Disaster recovery tested
  - **Test Date**: [YYYY-MM-DD]
  - **Result**: ✅ Successful / ❌ Failed
  - **Time to Recovery**: [Measured]
  - **Data Loss**: [Amount]

- [ ] **ACCEPT-005**: Team trained
  - **Training Completed**: [YYYY-MM-DD]
  - **Attendees**: [List]
  - **Competency**: ✅ Verified

- [ ] **ACCEPT-006**: Documentation complete
  - **Skills Document**: [Path]
  - **Runbooks**: [Number]
  - **Troubleshooting**: ✅ Complete
  - **Status**: ✅ Complete / 🟡 Partial / ❌ Incomplete

---

## Sign-Off

**Validator Name**: [Name]  
**Validator Title**: [Title]  
**Validation Date**: [YYYY-MM-DD]  
**Sign-Off Date**: [YYYY-MM-DD]  

**Status**:
- ✅ **APPROVED** - All items passed, agent ready for production
- 🟡 **APPROVED WITH CONDITIONS** - [List conditions]
- ❌ **REJECTED** - [Blocking issues listed below]

**Blocking Issues** (if any):
1. [Issue 1]: [Severity]
2. [Issue 2]: [Severity]

**Notes**:
[Any additional notes about validation]

---

## Re-Validation Schedule

**Next Validation**: [YYYY-MM-DD]  
**Frequency**: [Annually/Quarterly/After major changes]  
**Reason for Next Validation**: [Why]

---

## Previous Validations

| Date | Validator | Status | Notes |
|------|-----------|--------|-------|
| [YYYY-MM-DD] | [Name] | ✅/🟡/❌ | [Brief note] |

---

**Validation Version**: 1.0  
**Last Updated**: September 16, 2026  
**Template Owner**: Agent Team
```

---

## Usage Guidelines

### Before Validation

1. **Review the agent skills document** - understand what should be implemented
2. **Prepare the test environment** - staging or production candidate
3. **Gather the team** - developer, operator, security (if applicable)
4. **Review previous validations** - check if this is a re-validation

### During Validation

1. **Work through each section** - don't skip items
2. **Document everything** - note dates, times, people
3. **Test thoroughly** - don't just assume things work
4. **Record measurements** - performance, resource usage, recovery times
5. **Capture blockers** - document anything that fails

### After Validation

1. **Tabulate results** - count passed/failed items
2. **Identify issues** - categorize blocking vs. non-blocking
3. **Create action items** - for any failures
4. **Get sign-off** - from appropriate stakeholders
5. **Schedule re-validation** - if conditions apply
6. **Update master index** - mark agent as validated

---

## Validation Levels

**Level 1 - Unit**: Individual skills  
**Level 2 - Integration**: Skills + upstream/downstream  
**Level 3 - System**: Agent + full ecosystem  
**Level 4 - Production**: In production environment  

---

## Template Maintenance

**Last Updated**: September 16, 2026  
**Version**: 1.0  
**Maintainer**: Agent Team  

This template ensures rigorous, consistent, documented validation of all agents across all phases.
