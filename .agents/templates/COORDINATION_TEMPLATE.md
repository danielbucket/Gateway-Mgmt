# Agent Coordination Template

This template documents how agents coordinate and integrate with each other in the gateway management ecosystem.

---

## File Naming Convention

Format: `[AGENT1]_[AGENT2]_COORDINATION.md` (or `[AGENT_NAME]_INTEGRATIONS.md` for multi-agent coordination)

Examples:
- `DOCKER_NETWORK_COORDINATION.md`
- `LOGGING_PROMETHEUS_COORDINATION.md`
- `SERVICE_MESH_CI_CD_COORDINATION.md`

---

## Template Structure

```markdown
# [Agent 1] ⟷ [Agent 2] Coordination

**Status**: 🟢 Operational / 🟡 Planning / ⚪ Proposed  
**Coordination Type**: [Data Flow/Event-Driven/Direct API/Async Message]  
**Priority**: CRITICAL / HIGH / MEDIUM / LOW  
**Last Updated**: [YYYY-MM-DD]

---

## Coordination Overview

[2-3 sentence description of why these agents coordinate and what the coordination achieves]

### Coordination Goals

1. [Goal 1]: [Why it matters]
2. [Goal 2]: [Why it matters]
3. [Goal 3]: [Why it matters]

### Critical Path Items

- [Item 1]: [Why critical]
- [Item 2]: [Why critical]

---

## Agent Roles & Responsibilities

### [Agent 1 Name]

**Role in Coordination**: [What Agent 1 does]

**Responsibilities**:
- [Responsibility 1]
- [Responsibility 2]
- [Responsibility 3]

**Provides to [Agent 2]**:
- [Data/Service 1]
- [Data/Service 2]

**Requires from [Agent 2]**:
- [Data/Service 1]
- [Data/Service 2]

### [Agent 2 Name]

**Role in Coordination**: [What Agent 2 does]

**Responsibilities**:
- [Responsibility 1]
- [Responsibility 2]
- [Responsibility 3]

**Provides to [Agent 1]**:
- [Data/Service 1]
- [Data/Service 2]

**Requires from [Agent 1]**:
- [Data/Service 1]
- [Data/Service 2]

---

## Coordination Data Flow

### Flow Diagram

```
[ASCII diagram showing data flow between agents]

Example:

┌─────────────┐                    ┌──────────────┐
│  Docker     │                    │  Prometheus  │
│   Agent     │                    │    Agent     │
└──────┬──────┘                    └──────▲───────┘
       │                                  │
       │ Container metrics               │
       │ (via metrics endpoint)          │
       └──────────────────────────────────┘
```

### Data Elements

**[Agent 1] → [Agent 2]**:

| Data Element | Format | Frequency | Purpose |
|---|---|---|---|
| [Element 1] | [JSON/CSV/API] | [Real-time/Hourly/Daily] | [Why sent] |
| [Element 2] | [JSON/CSV/API] | [Real-time/Hourly/Daily] | [Why sent] |

**[Agent 2] → [Agent 1]**:

| Data Element | Format | Frequency | Purpose |
|---|---|---|---|
| [Element 1] | [JSON/CSV/API] | [Real-time/Hourly/Daily] | [Why sent] |
| [Element 2] | [JSON/CSV/API] | [Real-time/Hourly/Daily] | [Why sent] |

---

## Integration Architecture

### Coordination Protocol

**Type**: [REST/gRPC/Message Queue/Direct API/WebSocket/Polling]  
**Transport**: [HTTP/AMQP/Kafka/Direct Call/SSH/Custom]  
**Authentication**: [Method used]  
**Encryption**: [In transit/At rest]  
**Retry Policy**: [Exponential backoff/Immediate/None]

### API Endpoints / Integration Points

**[Agent 1] Exposes**:

```
Endpoint: [URL/Topic/Method]
Method: [GET/POST/SUBSCRIBE/etc]
Request Body:
{
  "field1": "[description]",
  "field2": "[description]"
}

Response:
{
  "status": "[success/failure]",
  "data": "[response data]"
}

Error Codes:
- 200/2xx: [What this means]
- 4xx: [What this means]
- 5xx: [What this means]
```

**[Agent 2] Exposes**:

[Similar format]

### Failure Scenarios

**When [Agent 1] is unavailable**:
- [Agent 2] behavior: [What happens]
- Timeout: [Timeout duration]
- Retry: [Retry policy]
- Fallback: [Fallback behavior]
- Recovery: [How to recover]

**When [Agent 2] is unavailable**:
- [Agent 1] behavior: [What happens]
- Timeout: [Timeout duration]
- Retry: [Retry policy]
- Fallback: [Fallback behavior]
- Recovery: [How to recover]

---

## Operational Procedures

### Startup Sequence

**Order**:
1. Start [Agent 1] first (or in parallel)
2. Start [Agent 2] second (or in parallel)
3. Verify coordination link

**Startup Checks**:
- [ ] [Check 1]
- [ ] [Check 2]

**Startup Issues**:
- **Issue**: [Problem]
  - **Solution**: [How to fix]

### Shutdown Sequence

**Order**:
1. Stop [Agent 2] first
2. Stop [Agent 1] second

**Pre-Shutdown Checks**:
- [ ] [Check 1]

### Health Check Procedure

**Frequency**: [How often]

**Checks**:
1. [Check 1]: Verify [Agent 1] is running
2. [Check 2]: Verify [Agent 2] is running
3. [Check 3]: Verify coordination link is working
4. [Check 4]: Verify data flow is current

**Success Criteria**:
- ✅ Both agents responding
- ✅ Data flowing in both directions
- ✅ No data loss or delays
- ✅ No error logs

### Coordination Validation

**Procedure**:
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Success Indicators**:
- [Indicator 1]
- [Indicator 2]

---

## Troubleshooting Guide

### Coordination Link Down

**Symptom**: [What users see]

**Diagnostic Steps**:
1. Check: [Step 1]
2. Check: [Step 2]

**Common Causes**:
- **Cause 1**: [Solution]
- **Cause 2**: [Solution]

**Recovery Procedure**:
1. [Step 1]
2. [Step 2]

### Data Not Flowing

**Symptom**: [What users see]

**Diagnostic Steps**:
1. Check: [Step 1]
2. Check: [Step 2]

**Common Causes**:
- **Cause 1**: [Solution]
- **Cause 2**: [Solution]

### Out of Sync

**Symptom**: [What users see]

**Diagnostic Steps**:
1. Check: [Step 1]
2. Check: [Step 2]

**Common Causes**:
- **Cause 1**: [Solution]
- **Cause 2**: [Solution]

**Resync Procedure**:
1. [Step 1]
2. [Step 2]

---

## Performance Characteristics

### Typical Performance

| Operation | Typical Time | P95 | P99 |
|---|---|---|---|
| [Agent 1] → [Agent 2] latency | [Time] | [Time] | [Time] |
| Data sync frequency | [Time] | - | - |

### Scaling Characteristics

- **Linear scaling**: [Yes/No] - reasoning
- **Bottleneck**: [What limits growth]
- **Max throughput**: [Capacity]

### Resource Impact

**On [Agent 1]**:
- CPU impact: [Percentage]
- Memory impact: [Amount]
- Network impact: [Bandwidth]

**On [Agent 2]**:
- CPU impact: [Percentage]
- Memory impact: [Amount]
- Network impact: [Bandwidth]

---

## Monitoring & Alerting

### Metrics to Monitor

| Metric | Target | Alert > | Alert < | Action |
|--------|--------|---------|---------|--------|
| [Metric 1] | [Target] | [Upper] | [Lower] | [Action] |
| [Metric 2] | [Target] | [Upper] | [Lower] | [Action] |

### Alert Rules

**SEV1** (Critical):
- [Alert 1]: [Condition that triggers]
- [Alert 2]: [Condition that triggers]

**SEV2** (High):
- [Alert 3]: [Condition that triggers]
- [Alert 4]: [Condition that triggers]

**SEV3** (Medium):
- [Alert 5]: [Condition that triggers]

### Logging

**Log Locations**:
- [Agent 1] logs: [Path]
- [Agent 2] logs: [Path]
- Coordination logs: [Path]

**Key Log Messages**:

**Success**:
```
[Sample log line showing successful coordination]
```

**Error**:
```
[Sample log line showing coordination error]
```

**Debug**:
```
[Sample debug log line]
```

---

## Dependencies & Prerequisites

### Deployment Order

1. Deploy [Agent 1] first: [Why]
2. Deploy [Agent 2] second: [Why]

**Reason**: [Agent 2] depends on [Agent 1] being operational

### Version Compatibility

| [Agent 1] Version | [Agent 2] Version | Compatible |
|---|---|---|
| [Version] | [Version] | ✅/⚠️/❌ |
| [Version] | [Version] | ✅/⚠️/❌ |

### Configuration Requirements

**[Agent 1] Configuration**:
- Setting 1: [Value/Reference]
- Setting 2: [Value/Reference]

**[Agent 2] Configuration**:
- Setting 1: [Value/Reference]
- Setting 2: [Value/Reference]

**Coordination Configuration**:
- Endpoint: [Actual endpoint]
- Timeout: [Actual timeout]
- Retry count: [Actual count]

---

## Testing & Validation

### Integration Test Plan

**Test 1: Basic Connectivity**
- **Objective**: Verify agents can communicate
- **Procedure**: [Steps]
- **Success Criteria**: [Criteria]

**Test 2: Data Flow**
- **Objective**: Verify data flows correctly
- **Procedure**: [Steps]
- **Success Criteria**: [Criteria]

**Test 3: Error Handling**
- **Objective**: Verify error scenarios handled correctly
- **Procedure**: [Steps]
- **Success Criteria**: [Criteria]

### Validation Checklist

- [ ] Both agents deployed
- [ ] Coordination link established
- [ ] Data flowing in both directions
- [ ] Performance meets targets
- [ ] Error scenarios tested
- [ ] Monitoring configured
- [ ] Runbooks documented
- [ ] Team trained

---

## Disaster Recovery

### Backup & Recovery

**Backup Strategy**:
- What to backup: [Data elements]
- Frequency: [Cadence]
- Retention: [How long]

**Recovery Steps**:
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Recovery Time Objective (RTO)**: [Target time]  
**Recovery Point Objective (RPO)**: [Maximum data loss]

---

## Security & Compliance

### Security Controls

- **Authentication**: [Method]
- **Authorization**: [Method]
- **Encryption in Transit**: [Method]
- **Encryption at Rest**: [Method]
- **Audit Logging**: [What's logged]
- **Access Control**: [Who can access]

### Compliance Requirements

- [Requirement 1]: [How met]
- [Requirement 2]: [How met]

### Security Incidents

**Known Issues**:
- [Issue 1]: Mitigated until [Date]
- [Issue 2]: Mitigated until [Date]

---

## Examples & Runbooks

### Example 1: [Scenario]

**Setup**:
```
[Configuration or setup steps]
```

**Execution**:
```
[How to run this scenario]
```

**Expected Result**:
```
[What should happen]
```

### Runbook: [Common Procedure]

**Objective**: [What this does]

**Prerequisites**:
- [ ] [Check 1]
- [ ] [Check 2]

**Steps**:
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Verification**:
- [ ] [Check 1]
- [ ] [Check 2]

---

## References & Links

- [Agent 1 Skills](.../[AGENT1]_AGENT_SKILLS.md)
- [Agent 2 Skills](.../[AGENT2]_AGENT_SKILLS.md)
- [Architecture Overview](.../AGENT_ECOSYSTEM_INDEX.md)
- [Phase/Domain Index](.../)
- [Related Coordination](.../[OTHER]_[COORDINATION].md)

---

## Change History

| Date | Version | Author | Changes |
|---|---|---|---|
| [YYYY-MM-DD] | 1.0 | [Author] | Initial version |

---

## Stakeholders & Support

**Primary Contact**: [Name, role]  
**Secondary Contact**: [Name, role]  
**Escalation**: [Path if issue unresolved]

---

**Coordination Type**: [Data Flow/Event/Direct API/Async]  
**Criticality**: CRITICAL / HIGH / MEDIUM / LOW  
**Status**: Planning / Alpha / Beta / Production  
**SLA**: [Availability target]
```

---

## Usage Guidelines

1. **Create one coordination file per major agent pair**
2. **Keep data flows clear** - use diagrams
3. **Document failure scenarios** - critical for operations
4. **Update when procedures change** - keep current
5. **Link to both agent skills files** - easy navigation
6. **Include runbooks** - make it actionable
7. **Specify dependencies** - clear deployment order

---

## When to Use This Template

- **Use this** for major agent-to-agent integrations
- **Use Agent Skills** for individual agent documentation
- **Link both** for complete understanding

---

## Template Maintenance

**Last Updated**: September 16, 2026  
**Version**: 1.0  
**Maintainer**: Agent Team  

This template ensures all coordination points are well-documented and operationally sound.
