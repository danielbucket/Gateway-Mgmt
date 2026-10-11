# Operational Agents - Quality Domain

**Location**: `agents/operational/quality/`  
**Purpose**: Quality assurance, validation, auditing, and guideline enforcement  
**Status**: 🟢 DEPLOYED (1 agent)

---

## Agents in This Domain

| Agent | Skills | Validation | Constraints | Purpose | Links |
|-------|--------|-----------|------------|---------|-------|
| Audit & Validation Agent | 7 | ~34 | ~24 | Quality gates, compliance audits, agent validation, drift detection | [Skills](./AUDIT_VALIDATION_AGENT_SKILLS.md) |

---

## Domain Overview

The Quality domain ensures all agents maintain standards and remain coordinated:

- **Pre-deployment validation** (12-step quality gates)
- **Structural completeness** audits (all required sections)
- **Cross-agent coordination** verification (bidirectional references)
- **Technical consistency** checks (IPs, ports, paths)
- **Constraint documentation** review (safety limits)
- **Guideline compliance** verification (markdown, structure)
- **Audit report generation** with remediation guidance

---

## Validation Workflows

### Pre-Deployment Validation (When creating new agent)
1. Structural completeness check
2. Required sections present
3. Cross-agent coordination verified
4. IPs & infrastructure consistency checked
5. Port allocations verified
6. Constraint documentation complete
7. Validation items defined (~20-24)
8. Integration matrix updated
9. Master index updated
10. Dependencies documented
11. Runbooks created
12. Security review passed

### Ongoing Compliance Audit (Quarterly)
- All agents reviewed for drift
- Cross-references validated
- IPs & topology checked
- Port mappings verified
- Constraint compliance confirmed
- Documentation currency verified

### Gap Detection Audit (After changes)
- New agent coordination verified
- Integration points checked
- Dependency consistency confirmed
- Communication gaps identified
- Remediation recommendations provided

---

## Quality Standards

All agents must comply with:
- **Skills Markdown Guideline** (format, sections, structure)
- **Coordination standards** (bidirectional references)
- **Technical accuracy** (IPs, ports, paths match reality)
- **Constraint documentation** (safety limits defined)
- **Validation completeness** (20+ items per agent)
- **Security requirements** (no hardcoded secrets)
- **Integration documentation** (all connections mapped)

---

## Key Integrations

Audit & Validation Agent depends on / integrates with:
- **All operational agents** (validation target)
- **All planned agents** (pre-deployment validation)
- **Network Infrastructure Agent** (IP topology validation)
- **Skills Markdown Guideline** (compliance standards)
- **Disaster Recovery Agent** (procedure audits)

---

## Quality Metrics

| Metric | Current | Target |
|--------|---------|--------|
| Agents in compliance | 8/8 | 23/23 |
| Cross-agent refs | 7x7 matrix | Full coverage |
| Validation items | 180+ | 470+ |
| Constraints documented | 160+ | 380+ |
| Documentation currency | 100% | 100% |
| Pre-deployment pass rate | N/A | 100% |

---

## Audit Reports

Reports include:
- **Compliance status** (pass/fail per agent)
- **Issues found** (structure, coordination, consistency)
- **Line numbers** (specific locations needing fixes)
- **Remediation steps** (how to fix each issue)
- **Priority levels** (critical, major, minor)
- **Estimated effort** (fix time)

Example issues:
- ❌ Agent A doesn't reference Agent B (but B references A)
- ❌ Port 22 assigned to both Jumpbox and another service
- ❌ IP 24.204.72.65 used twice (conflict)
- ❌ Validation checklist has only 15 items (needs 20+)
- ⚠️ Constraint "Max connections: 100" not verified

---

## Quick Links

- [Audit & Validation Agent Skills](./AUDIT_VALIDATION_AGENT_SKILLS.md)
- [Master Index](../../../AGENT_ECOSYSTEM_INDEX.md)
- [Skills Markdown Guideline](../../_core/SKILLS_MARKDOWN_GUIDELINE.md) (standards)
- [Deployment Procedures](../../../procedures/DEPLOYMENT_PROCEDURES.md)
- [All Agent Templates](../../../templates/)

---

## Quality Improvement Process

```
┌─────────────────────────────────────────────────────────────┐
│            Quality Assurance & Validation Flow               │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  1. New Agent Created                                        │
│     ↓                                                         │
│  2. Pre-Deployment Validation                               │
│     ├─ Structural check                                      │
│     ├─ Coordination check                                    │
│     └─ Technical consistency check                           │
│     ↓                                                         │
│  3. Issues Found?                                            │
│     ├─ YES: Remediation required → Re-validate              │
│     └─ NO: Proceed                                           │
│     ↓                                                         │
│  4. Agent Deployed                                           │
│     ↓                                                         │
│  5. Quarterly Compliance Audit                              │
│     ├─ Drift detection                                       │
│     ├─ Consistency verification                              │
│     └─ Documentation review                                  │
│     ↓                                                         │
│  6. Issues Found?                                            │
│     ├─ YES: Issue tracking → Fix → Re-audit                 │
│     └─ NO: Continue operations                               │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

---

## Running an Audit

```bash
# Pre-deployment validation (new agent)
./audit-agent validate-agent <agent_skills_file>

# Structural audit (all agents)
./audit-agent audit-structure

# Consistency audit (IPs, ports, paths)
./audit-agent audit-consistency

# Coordination audit (cross-references)
./audit-agent audit-coordination

# Full ecosystem audit
./audit-agent audit-full

# Generate report
./audit-agent report [--format=html|markdown|json]
```

---

## Common Issues & Fixes

| Issue | Symptom | Fix |
|-------|---------|-----|
| Missing coordination | Agent A doesn't know about Agent B | Add references in both agents, update matrix |
| IP conflict | Two agents using same IP | Verify against Network Infrastructure Agent |
| Port conflict | Two services on same port | Check Transmission Protocol Agent allocation |
| Validation count low | Only 15 items (need 20+) | Review Validation Checklist Template |
| Constraint missing | No safety limits documented | Review Constraint Guidelines |
| Outdated docs | Agent description doesn't match reality | Run git diff, update from source of truth |

---

**Last Updated**: September 16, 2026  
**Status**: Production Operational (validates all agents)  
**Next Review**: Quarterly or after deploying new agents  
**Audit Schedule**: Weekly (automated), Monthly (manual), Quarterly (comprehensive)
