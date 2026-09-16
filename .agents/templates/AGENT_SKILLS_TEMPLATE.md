# Agent Skills Template

This template defines the standard format for all agent skill documentation in the gateway management system.

---

## File Naming Convention

Format: `[AGENT_NAME]_AGENT_SKILLS.md`

Examples:
- `DOCKER_AGENT_SKILLS.md`
- `STORAGE_BACKUP_AGENT_SKILLS.md`
- `LOGGING_AGENT_SKILLS.md`

---

## Template Structure

```markdown
# [Agent Name] Agent Skills

**Status**: 🟢 Deployed / 🟡 TODO / ⚪ Planned  
**Phase**: [Phase number or "Operational"]  
**Timeline**: [Deployment date or "Weeks X-Y"]  
**Owner**: [Team/person responsible]  
**Last Updated**: [YYYY-MM-DD]

---

## Overview

[2-3 sentence description of this agent's primary purpose and critical role]

### Core Responsibilities

- [Responsibility 1: Brief description]
- [Responsibility 2: Brief description]
- [Responsibility 3: Brief description]
- [... up to 10-15 core responsibilities]

### Integration Points

- **Upstream Dependencies**: [Agents that must be in place first]
- **Downstream Integrations**: [Agents that depend on this one]
- **External Integrations**: [Third-party services, APIs, tools]

---

## Skills Matrix

Total Skills: [X] | Validation Items: ~[Y] | Constraints: ~[Z]

| # | Skill Name | Description | Status | Difficulty |
|---|---------|-------------|--------|------------|
| 1 | [Skill 1] | [What this skill does] | ✅/🟡 | Low/Medium/High |
| 2 | [Skill 2] | [What this skill does] | ✅/🟡 | Low/Medium/High |
| ... | ... | ... | ... | ... |

### Skill Categories

**[Category 1 - e.g., "Core Operations"]** (Skills #1-3)
- Skill 1: Description
- Skill 2: Description
- Skill 3: Description

**[Category 2 - e.g., "Monitoring & Health"]** (Skills #4-6)
- Skill 4: Description
- Skill 5: Description
- Skill 6: Description

---

## Detailed Skill Descriptions

### Skill 1: [Skill Name]

**Purpose**: [Why this skill is important]

**Key Procedures**:
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Validation Items**:
- [ ] [Validation criterion 1]
- [ ] [Validation criterion 2]
- [ ] [Validation criterion 3]

**Common Issues & Troubleshooting**:
- **Issue**: [Problem description]
  - **Cause**: [Root cause]
  - **Solution**: [How to fix it]

**Related Skills**: [Skills 2, 5, 7]

---

[Repeat "Detailed Skill Descriptions" section for each skill]

---

## Validation Checklist

✅ **Operational Validation** (~[Y] items total):

### Pre-Deployment
- [ ] [Validation 1]
- [ ] [Validation 2]

### Deployment
- [ ] [Validation 3]
- [ ] [Validation 4]

### Post-Deployment
- [ ] [Validation 5]
- [ ] [Validation 6]

---

## Constraints & Limits

⚠️ **Critical Constraints** (~[Z] total):

| Constraint | Value | Reason | Mitigation |
|-----------|-------|--------|-----------|
| [Constraint 1] | [Limit] | [Why it matters] | [How to handle] |
| [Constraint 2] | [Limit] | [Why it matters] | [How to handle] |

---

## Architecture & Design

### Deployment Model

**Primary Location**: [Node/Service]  
**Backup Location**: [Node/Service]  
**Network Requirements**: [Ports, protocols]  
**Resource Requirements**: [CPU, memory, disk]

### Architecture Diagram

```
[ASCII Diagram showing this agent's role in the system]

Example:
┌──────────────────────┐
│   Docker Agent       │
│  (Service Control)   │
└──────────┬───────────┘
           │
     ┌─────┴─────┐
     ▼           ▼
[Service A]  [Service B]
```

---

## Integration Guide

### Upstream Dependencies

**Must Deploy First**:
- [Agent 1] - [Why needed]
- [Agent 2] - [Why needed]

**How to Verify Readiness**:
1. [Check 1]
2. [Check 2]

### Downstream Integrations

**These Agents Depend on This One**:
- [Agent 3] - [How it depends]
- [Agent 4] - [How it depends]

**Integration Points**:
| Dependent Agent | Integration Type | Details |
|---|---|---|
| [Agent X] | [REST/Event/Direct] | [API endpoint/topic/method] |

---

## Operations & Procedures

### Startup Procedure

**Pre-Startup Checks**:
- [ ] [Check 1]
- [ ] [Check 2]

**Startup Steps**:
1. [Step 1]
2. [Step 2]

**Post-Startup Validation**:
- [ ] [Validation 1]
- [ ] [Validation 2]

### Shutdown Procedure

**Pre-Shutdown Checks**:
- [ ] [Check 1]

**Shutdown Steps**:
1. [Step 1]
2. [Step 2]

### Health Check Procedure

**Frequency**: [Daily/Weekly/Monthly]

**Checks to Perform**:
1. [Health check 1]
2. [Health check 2]

**Success Criteria**:
- ✅ [Criterion 1]
- ✅ [Criterion 2]

### Update/Upgrade Procedure

**Update Frequency**: [Recommended cadence]

**Pre-Update**:
- [ ] Backup [Data]
- [ ] Notify [Teams]

**Update Steps**:
1. [Step 1]
2. [Step 2]

**Post-Update Validation**:
- [ ] [Validation 1]
- [ ] [Validation 2]

---

## Troubleshooting Guide

### [Issue Category 1 - e.g., "Connection Issues"]

**Symptom**: [What users see]

**Diagnostic Steps**:
1. Check: [Command/procedure 1]
2. Check: [Command/procedure 2]

**Common Causes & Solutions**:
- **Cause 1**: Solution
- **Cause 2**: Solution

**Escalation Path**: [Who to contact if unresolved]

---

### [Issue Category 2]

[Similar structure]

---

## Monitoring & Alerting

### Metrics to Monitor

| Metric | Target | Alert Threshold | Action |
|--------|--------|-----------------|--------|
| [Metric 1] | [Target value] | [Red/Yellow] | [Response] |
| [Metric 2] | [Target value] | [Red/Yellow] | [Response] |

### Alert Rules

**SEV1 Alerts** (Critical - immediate response):
- [Alert 1]: [Condition]
- [Alert 2]: [Condition]

**SEV2 Alerts** (High - within 1 hour):
- [Alert 3]: [Condition]
- [Alert 4]: [Condition]

**SEV3 Alerts** (Medium - within 1 business day):
- [Alert 5]: [Condition]

### Logging & Diagnostics

**Log Locations**:
- [Log path 1]
- [Log path 2]

**Log Levels**:
- INFO: [What's logged]
- WARN: [What's logged]
- ERROR: [What's logged]

---

## Performance Characteristics

### Typical Performance

| Operation | Typical Time | P95 Time | P99 Time |
|-----------|-------|----------|----------|
| [Operation 1] | [Time] | [Time] | [Time] |
| [Operation 2] | [Time] | [Time] | [Time] |

### Scaling Characteristics

- **Horizontal Scaling**: [Supported/Limited/Not Supported]
- **Vertical Scaling**: [Supported/Limited/Not Supported]
- **Recommended Max**: [Capacity limit]

---

## Disaster Recovery

### Backup Strategy

**Frequency**: [Backup cadence]  
**Retention**: [How long kept]  
**Storage**: [Where backups stored]  
**Verification**: [How backups tested]

### Recovery Procedure

**Recovery Point Objective (RPO)**: [Maximum data loss acceptable]  
**Recovery Time Objective (RTO)**: [Maximum downtime acceptable]

**Recovery Steps**:
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Post-Recovery Validation**:
- [ ] [Check 1]
- [ ] [Check 2]

---

## Security & Compliance

### Security Controls

- **Authentication**: [Method]
- **Authorization**: [Method]
- **Encryption**: [In transit/At rest]
- **Audit Logging**: [What's logged]

### Compliance Requirements

- [Requirement 1]: [How met]
- [Requirement 2]: [How met]

### Known Security Issues

- [Issue 1]: Mitigation in place until [Target date]
- [Issue 2]: Mitigation in place until [Target date]

---

## Dependencies & Versions

### Required Software

| Component | Min Version | Recommended | Max Version |
|-----------|------------|-------------|------------|
| [Dependency 1] | [Version] | [Version] | [Version] |
| [Dependency 2] | [Version] | [Version] | [Version] |

### External Service Dependencies

- [Service 1]: Required for [Purpose]
- [Service 2]: Required for [Purpose]

---

## Quick Reference

### Common Commands

```bash
# Start the agent
[Start command]

# Check status
[Status command]

# View logs
[Log command]

# Stop the agent
[Stop command]
```

### Key Endpoints/URLs

- [Endpoint 1]: [URL/Address]
- [Endpoint 2]: [URL/Address]

### Emergency Contacts

- **Technical Lead**: [Name, contact]
- **On-Call**: [Rotation/contact info]

---

## References & Links

- [AGENT_ROADMAP.md](../../AGENT_ROADMAP.md) - Implementation timeline
- [AGENT_ECOSYSTEM_INDEX.md](../../AGENT_ECOSYSTEM_INDEX.md) - All agents
- [Phase X Overview](../phase-X-name/index.md) - Phase details
- [Related Agent Skills](./[RELATED]_AGENT_SKILLS.md) - Integration guide

---

## Change History

| Date | Version | Author | Changes |
|------|---------|--------|---------|
| [YYYY-MM-DD] | 1.0 | [Author] | Initial version |

---

## Appendix

### A. Configuration Examples

[Example configurations showing typical setups]

### B. Advanced Procedures

[Less common but important procedures]

### C. Glossary

[Technical terms specific to this agent]

---

**Agent Type**: [Operational/Planning/Support]  
**Maturity**: [Planned/Alpha/Beta/Production]  
**SLA**: [Availability target]  
**Support**: [How to get help]
```

---

## Usage Guidelines

1. **Copy this template** for each new agent
2. **Replace all [bracketed sections]** with actual content
3. **Follow the structure** - don't skip sections
4. **Keep it current** - update when skills or procedures change
5. **Link to other agents** - document dependencies clearly
6. **Include examples** - show real-world usage
7. **Make it searchable** - use clear headers and tables

---

## Template Maintenance

**Last Updated**: September 16, 2026  
**Version**: 1.0  
**Maintainer**: Agent Team  

This template ensures consistency across all 23 agents and makes them easier to navigate, understand, and maintain.
