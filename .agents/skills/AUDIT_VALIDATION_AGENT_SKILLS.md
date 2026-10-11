# AUDIT & VALIDATION AGENT SKILLS

> ⚠️ **Deprecated mirror file**.
> Canonical source: `.agents/agents/operational/quality/AUDIT_VALIDATION_AGENT_SKILLS.md`. Update and reference the canonical file only.

**Agent Purpose:**  
Ensure all agent skills files maintain structural completeness, technical consistency, bidirectional cross-channel coordination, and compliance with the SKILLS_MARKDOWN_GUIDELINE. This agent proactively validates new agents during creation and conducts periodic audits of existing agents to prevent documentation drift, coordination gaps, and operational blind spots.

**Primary Responsibilities:**
- Validate new agent skills files before deployment
- Audit existing agent skills for consistency and completeness
- Verify bidirectional cross-agent coordination
- Enforce SKILLS_MARKDOWN_GUIDELINE compliance
- Identify and flag coordination gaps
- Generate detailed audit reports with remediation guidance
- Maintain comprehensive coordination matrix
- Document infrastructure topology consistency
- Prevent operational incidents caused by documentation gaps

---

## Architecture & Context

### Integration Points
The Audit & Validation Agent operates as a **quality control layer** across the entire multi-agent ecosystem:

| Integration | Purpose | Key Coordination |
|---|---|---|
| **DOCKER_AGENT_SKILLS** | Container orchestration oversight | Validates Swarm configuration, service discovery labels, logging driver coordination |
| **NETWORK_AGENT_SKILLS** | Firewall & routing oversight | Validates port coordination matrix, firewall rules, VPN access documentation |
| **PROMETHEUS_AGENT_SKILLS** | Monitoring consistency oversight | Validates exporter scripts, scrape intervals, metric retention policies |
| **WIREGUARD_AGENT_SKILLS** | VPN coordination oversight | Validates peer topology, key rotation procedures, jumpbox access patterns |
| **SAMBA_AGENT_SKILLS** | File sharing consistency oversight | Validates container deployment, share configuration, remote access procedures |
| **SKILLS_MARKDOWN_GUIDELINE** | Standards enforcement | Validates template compliance, multi-agent coordination patterns, documentation structure |

### Infrastructure Context
The audit agent validates against a known infrastructure topology:

**Network Topology (24.204.72.64/26):**
- Gateway: 24.204.72.65 (Docker manager, Prometheus, Samba)
- SpaceBase: 24.204.72.66 (Docker worker, Samba)
- hyperdrive: 24.204.72.67 (WireGuard peer)
- Laboratory: 24.204.72.68 (WireGuard peer)

**Critical Port Allocations:**
- Docker: 2222/tcp, 5000-5999/tcp, 8000-9999/tcp, 2377/tcp, 7946/tcp+udp, 4789/udp
- Prometheus: 9090/tcp, 9093/tcp, 9100/tcp
- WireGuard: 51820/udp
- Samba: 445/tcp, 137-138/udp

**Standard File Paths:**
- `/usr/local/bin/wireguard-exporter.sh` (WireGuard metrics)
- `/usr/local/bin/samba-exporter.sh` (Samba metrics)
- `/etc/samba/smb.conf` (Samba configuration)
- `/etc/wireguard/` (WireGuard configs)
- `/etc/prometheus/` (Prometheus configs)
- `/etc/ufw/` (Firewall rules)

**Operational Constants:**
- Prometheus scrape interval: 15 seconds
- Exporter timeout: 10 seconds maximum
- Metric retention: 30 days
- Max concurrent Samba users: 10

---

## Skill Area 1: Pre-Deployment Agent Validation

**Purpose:** Validate new agent skills files before they enter the operational ecosystem.

**Capabilities:**
- Structural completeness verification (all required sections present)
- Skill area count validation (5-9 skill areas recommended)
- Diagnostic workflow count verification (3-6 workflows per agent)
- Validation checklist comprehensiveness (12+ items recommended)
- Constraint documentation review (6+ constraints minimum)
- Best practices documentation review (8+ recommendations minimum)
- Cross-agent reference validation (must mention all applicable agents)
- File path consistency checks against known standard locations
- Port number validation against established allocation scheme
- Network IP address consistency against infrastructure topology

**Examples:**
1. **Validate New VPN Agent:** Check that new VPN-focused agent skills file includes all required sections, documents coordination with Docker (containers), Network (firewall), Prometheus (exporter), and references established port allocations (51820/udp)

2. **Validate Container Agent Expansion:** Ensure expanded Docker agent includes sections for new orchestration patterns, maintains firewall coordination with Network agent, coordinates logging with Prometheus agent, documents exporter script paths correctly

3. **Validate Storage Agent Addition:** Before deploying new storage agent, verify it documents SMB port coordination (445/tcp, 137-138/udp), cross-references Samba agent, includes container deployment procedures, validates file paths in /etc/storage/ (if applicable)

4. **Quick Compliance Check:** Run rapid validation on new agent to ensure at minimum: Overview section present, 5+ skill areas, Architecture Context, all known agents mentioned in Reference Implementation, validation checklist >12 items

5. **Standards Audit Before Merge:** Validate agent skills against SKILLS_MARKDOWN_GUIDELINE before PR merge, checking adherence to markdown formatting, coordination pattern usage, multi-agent example quality

6. **Integration Readiness Assessment:** Before new agent goes live, verify coordination matrix is complete (all existing agents updated with new agent references), bidirectional mentions present, firewall/port coordination documented in Network agent

7. **Template Compliance Deep Dive:** For new agent, validate that Overview uses proper structure, Skill Areas follow pattern (1-2 sentence title, detailed capabilities, 3-7 examples, constraints), Diagnostic Workflows follow troubleshooting format

**Constraints:**
- Cannot validate against infrastructure elements not yet deployed (e.g., cannot verify storage capacity until deployed)
- Port validation requires Network agent to be source of truth (Network agent port lists are authoritative)
- Cannot assess operational feasibility without infrastructure context (validation is documentation-only)
- Cross-agent references must be bidirectional (if new agent mentions Docker, Docker must mention new agent in return)
- Skill areas must be distinct (no duplication across agent boundaries)
- All example tasks must be testable/verifiable (no theoretical or "future" capabilities)
- Validation checklist items must be pre-deployment checks (not operational procedures)
- File paths must follow established conventions (/usr/local/bin/ for scripts, /etc/ for configs)
- Network addresses must fall within documented 24.204.72.64/26 range
- Cannot validate internal logic correctness (only documentation structure and coordination)

---

## Skill Area 2: Structural Completeness Auditing

**Purpose:** Audit existing agent skills files to ensure all required sections remain intact and comprehensive.

**Capabilities:**
- Overview section quality review (agent purpose, scope clearly stated)
- Architecture Context completeness (infrastructure details, integration points documented)
- Skill Area presence verification (expected count per agent: Docker 6, Network 5, Prometheus 6, WireGuard 9, Samba 7)
- Skill Area structure validation (title, capabilities, examples, constraints format)
- Diagnostic Workflow presence (minimum 3-6 per agent type)
- Diagnostic Workflow structure (title, steps, expected outcomes documented)
- Best Practices section completeness (8-12 recommendations per agent)
- Validation Checklist completeness (12-21 items per agent)
- Reference Implementation presence (cross-agent links documented)
- Table of contents accuracy (if present, sections correctly listed)

**Examples:**
1. **Quarterly Audit Cycle:** Run structural audit on all 5 operational agents to verify no sections have been accidentally deleted, all skill areas intact, diagnostic workflows present, validation checklists >12 items

2. **Post-Emergency Fix Validation:** After emergency operational change, audit affected agent skills to ensure no sections were removed, documentation wasn't simplified, validation procedures still comprehensive

3. **Documentation Migration Check:** When moving agent skills files between locations/repositories, verify all sections survived migration, no content truncation, structure remains intact

4. **Skill Area Count Verification:** Audit that Docker maintains 6 skill areas, Network maintains 5, Prometheus maintains 6, WireGuard maintains 9, Samba maintains 7 (baseline expectations)

5. **Diagnostic Workflow Audit:** Ensure each operational agent has minimum 3 diagnostic workflows (Network minimum), most agents have 5-6, WireGuard and Samba maintain 6 each

6. **Validation Checklist Expansion:** Audit validation checklists to confirm they contain 12+ items for simpler agents (Docker, Network), 14+ for moderate agents (Prometheus), 21+ for complex agents (Samba, WireGuard)

7. **Reference Implementation Link Check:** Verify Reference Implementation sections in all agents include links to all other applicable agents, not just subset

**Constraints:**
- Cannot verify section content quality (only presence/structure, not accuracy)
- Cannot validate that examples are still current (requires operator review)
- Section ordering is flexible (Audit Agent doesn't enforce specific order)
- Different agent types have different expectations (Audit Agent must account for agent type)
- Cannot detect subtle documentation drift (only missing sections or insufficient items)
- Skill area count may vary for future agents (5-9 is recommended range, not hard requirement)
- Cannot compare against external standards (only against internal SKILLS_MARKDOWN_GUIDELINE)

---

## Skill Area 3: Cross-Agent Coordination Validation

**Purpose:** Verify bidirectional cross-agent references and comprehensive coordination documentation.

**Capabilities:**
- Bidirectional reference matrix verification (all agents mention all applicable agents)
- Coordination mention counting ("coordinated with", "Coordinate with" pattern search)
- Reference Implementation section audit (each agent has section linking to others)
- Integration point documentation (Docker/Network/Prometheus/WireGuard/Samba connections clear)
- Coordination gap detection (agent A mentions B, but B doesn't mention A = gap)
- Missing agent references identification (new agent exists but not referenced in old agents)
- Over-coordination detection (agents mention non-applicable services)
- Coordination depth analysis (67+ explicit coordination points across all agents as baseline)
- Cross-agent dependency mapping (which skills depend on which other agents)
- Coordination pattern validation (multi-agent workflows documented in Reference Implementation)

**Examples:**
1. **Complete Coordination Matrix Check:** Run audit verifying Docker mentioned in Network/Prometheus/WireGuard/Samba, Network mentioned in Docker/Prometheus/WireGuard/Samba, etc. = 5x5 matrix fully bidirectional

2. **New Agent Integration Audit:** After new agent created, scan all existing agents to verify they reference new agent in Reference Implementation sections, new agent references all existing agents

3. **Coordination Gap Detection:** Audit detects "Docker mentioned in 4 files but Network only mentions Docker in Samba context" = gap. Flag for remediation: add explicit Docker coordination to Network Reference Implementation

4. **Overcoordination Detection:** If Network agent includes detailed Prometheus exporter script management (should be Prometheus responsibility), flag as scope creep and recommend consolidation

5. **Coordination Depth Analysis:** Audit counts total "coordinated with" mentions across entire ecosystem (baseline 67), alerts if count drops below 60 (indicates missing coordination), trends above 75 (indicates overdocumentation)

6. **Integration Point Review:** Audit verifies Docker coordination mentions include specific ports (2222, 5000-5999, 8000-9999), not generic "coordinates with Docker"

7. **Dependency Chain Mapping:** Audit identifies that "Samba depends on Docker (containers) depends on Network (firewall) depends on [nothing]" = proper layered dependency, flags circular dependencies if found

8. **Missing Reference Updates:** After modifying agent coordination, run audit to verify all 5 affected agents updated their Reference Implementation sections, no agents missed

**Constraints:**
- Cannot validate coordination workflow correctness (only that references exist)
- Bidirectional requirement is strict (even asymmetric relationships must document reason for asymmetry)
- Coordination must be explicit in Reference Implementation (implicit coordination in Skill Areas insufficient)
- Cannot determine if coordination is necessary or unnecessary without operator judgment
- Different agent types may have different coordination patterns (some may not need certain agent references)
- "Coordinated with" mentions must be in specific sections (not scattered throughout document)
- Cannot detect stale coordination references (agent A mentions B for something B doesn't do anymore)
- Coordination depth baseline (67 mentions) specific to current 5-agent ecosystem (changes with new agents)

---

## Skill Area 4: Technical Consistency & Accuracy Auditing

**Purpose:** Verify that network addresses, port numbers, file paths, and infrastructure details remain consistent across all agent documentation.

**Capabilities:**
- Network IP address consistency checking (24.204.72.65, 24.204.72.66, 24.204.72.67, 24.204.72.68 all consistent)
- Port number validation across all agents (2222, 5000-5999, 8000-9999, 9090, 9093, 9100, 51820, 445, 137-138)
- Port range validation (dev ports 8000-9999 vs 8000-8999 incorrect detection)
- File path consistency verification (/usr/local/bin/wireguard-exporter.sh, /usr/local/bin/samba-exporter.sh, /etc/samba/smb.conf)
- Command syntax validation (docker, smbclient, iptables commands match actual tool syntax)
- Time interval consistency (15-second Prometheus scrape, 10-second exporter timeout, 30-day retention)
- Service port collision detection (no two services using same port)
- Infrastructure topology consistency (Gateway as primary, SpaceBase as secondary documented consistently)
- Configuration file location consistency (/etc/prometheus/, /etc/wireguard/, /etc/ufw/ paths)
- Concurrent connection limit consistency (max 10 SMB connections documented consistently)

**Examples:**
1. **Network Topology Audit:** Verify all agents reference 24.204.72.65 as Gateway (count mentions: 99+), 24.204.72.64/26 as network range (20+ mentions), SpaceBase as 24.204.72.66, hyperdrive/Laboratory as 24.204.72.67/5

2. **Port Collision Detection:** Audit detects if any two services attempt to use same port, or if port range (8000-9999) documented inconsistently in different agents

3. **File Path Consistency Check:** Verify wireguard-exporter.sh referenced consistently across all files where it appears (12 references in WireGuard agent), Samba exporter in 11 references, smb.conf in 27 references

4. **Command Syntax Validation:** Audit verifies docker exec command examples are syntactically correct, smbclient commands include correct parameters, iptables rules follow proper syntax

5. **Time Interval Verification:** Confirm all agents document Prometheus scrape as 15 seconds (not 10, not 20), exporter timeout as maximum 10 seconds, metric retention as 30 days

6. **Infrastructure Topology Consistency:** Verify Docker documented on 24.204.72.65 and 24.204.72.66 consistently, Prometheus only on 24.204.72.65, WireGuard peers on documented addresses

7. **Configuration Path Consistency:** Audit that /etc/samba/ used consistently for Samba configs (not /etc/smb/ or /etc/samba-config/), /etc/wireguard/ for WireGuard, /etc/prometheus/ for Prometheus

8. **Storage Specification Consistency:** Verify Samba media share always documented as 1.990TB, backups as 1TB, miscellanea as unlimited, max concurrent users always 10

**Constraints:**
- Cannot validate if documented addresses actually exist in infrastructure (topology accuracy requires deployment verification)
- Command syntax validation is basic (only obvious errors caught, complex syntax issues may be missed)
- Cannot verify if ports are actually open/working (only that documentation is consistent)
- Floating point precision issues with storage (1.990TB vs 1.99TB vs 2TB should normalize)
- Time intervals may need to be configurable in future (15 seconds currently standard, may change)
- Port ranges may expand/contract (8000-9999 currently correct, must update baseline if ranges change)
- File paths may be customized per installation (audit validates consistency, not absolute correctness)
- Infrastructure topology is for internal 24.204.72.64/26 only (external peer topology may differ)
- Cannot detect stale IP addresses (e.g., if 24.204.72.68 node decommissioned but still documented)

---

## Skill Area 5: Constraint & Safety Documentation Review

**Purpose:** Audit constraint documentation to ensure all failure modes, safety limits, and operational guardrails are clearly documented.

**Capabilities:**
- Constraint presence verification (6+ constraints per simple agent, 20+ per complex agent)
- Constraint categorization validation (operational limits, authentication/authorization, performance bounds)
- Safety guardrail documentation (max concurrent connections, timeout thresholds, resource limits)
- Failure mode identification (documented outcomes when constraints violated)
- Best practices documentation (8-12 recommendations per agent)
- Anti-pattern documentation (what NOT to do clearly stated)
- Concurrent access limit documentation (Samba 10-user max, Docker service limits)
- Resource limit documentation (Prometheus 2GB limit, 30-day retention)
- Security constraint documentation (guest access disabled, key rotation required)
- Performance constraint documentation (15-second scrape window, 10-second exporter timeout)

**Examples:**
1. **Constraint Inventory Audit:** Verify Docker agent has 20 constraints documented, Network has 6, Prometheus has 16, WireGuard has 29, Samba has 20 = 91 total constraints

2. **Safety Guardrail Review:** Audit confirms "no guest SMB access" constraint documented in Samba agent, "10 concurrent user maximum" constraint present, firewall precedence rules documented in Network agent

3. **Best Practices Completeness:** Verify each agent has 8+ best practice recommendations (Docker 8, Prometheus 9, WireGuard 10, Samba 12), Network agent may need enhancement (currently 0, recommend 8+)

4. **Failure Mode Documentation:** Audit checks that constraints include what happens when violated (e.g., "If >10 concurrent SMB users: connection refused", "If Prometheus >2GB: oldest metrics deleted")

5. **Resource Limit Documentation:** Verify Prometheus 2GB storage limit documented with retention policy (30 days), Samba 1.990TB media capacity documented with growth strategy

6. **Security Constraint Validation:** Audit ensures guest access disabled constraint appears in both Samba and Network agent (SMB firewall rules), Docker authentication requirements documented

7. **Performance Bound Review:** Confirm Prometheus 15-second scrape documented with timeout (10 seconds), alert thresholds defined (when metrics delayed >15s), exporter failure modes documented

8. **Anti-Pattern Documentation:** Audit identifies if agents document what NOT to do (e.g., "Do not manually restart Samba without draining connections", "Do not modify iptables during active VPN tunnels")

**Constraints:**
- Cannot determine if constraint limits are correct (accuracy requires operational experience)
- Cannot validate if all possible failure modes documented (only that major ones are present)
- Best practices are subjective (audit validates presence/quantity, not quality)
- Constraint specificity varies (some constraints generic, some very specific to infrastructure)
- Cannot detect if constraints are still enforced (documentation audit only, not compliance check)
- Resource limits may need adjustment (2GB Prometheus retention may be inadequate in production)
- Some constraints may be implementation-specific (e.g., max concurrent users depends on hardware)

---

## Skill Area 6: Guideline Compliance Verification

**Purpose:** Ensure all agent skills files adhere to the SKILLS_MARKDOWN_GUIDELINE patterns and standards.

**Capabilities:**
- Guideline section structure compliance (Overview, Architecture Context, Skill Areas, Workflows, Checklists, Reference Implementation present)
- Markdown formatting validation (proper heading levels, code block formatting, table structure)
- Multi-agent coordination pattern verification (agents use recommended coordination patterns from Guideline)
- Skill Area naming conventions (title format, capability organization matches guideline examples)
- Diagnostic workflow structure compliance (Steps, Expected Outcomes, Prerequisites documented as guideline specifies)
- Validation checklist format compliance (checkbox items [ ], pre-deployment focus, measurable checks)
- Best practices structure compliance (specific recommendations with rationale, not generic advice)
- Example task quality (concrete, infrastructure-specific, testable per guideline)
- Code sample formatting (proper syntax highlighting, commands are actual executable commands)
- Cross-reference pattern compliance (Reference Implementation follows guideline format)

**Examples:**
1. **New Agent Template Validation:** Validate new agent follows SKILLS_MARKDOWN_GUIDELINE structure exactly (Overview section, Architecture Context, 5-9 Skill Areas, 3-6 Diagnostic Workflows, Validation Checklist, Reference Implementation)

2. **Markdown Formatting Audit:** Verify all agents use consistent heading levels (# for main title, ## for sections, ### for subsections), code blocks have language specifiers (```bash not just ```), tables properly formatted

3. **Multi-Agent Pattern Check:** Audit that all agents use multi-agent coordination patterns from Guideline (e.g., "Coordinated with X Agent: Y capability", "Reference Implementation lists all applicable agents")

4. **Skill Area Convention Compliance:** Verify each skill area follows guideline format (1-2 sentence title, "Capabilities:" subsection, "Examples:" with 3-7 concrete tasks, "Constraints:" with 5+ items)

5. **Workflow Structure Compliance:** Audit ensures Diagnostic Workflows include: title, problem description, numbered steps, expected outcomes, prerequisites, applicable agents involved

6. **Checklist Item Validation:** Verify all checklist items follow format ([ ] checkbox, pre-deployment only, measurable/verifiable, specific to infrastructure)

7. **Best Practices Guideline Compliance:** Audit that best practices include rationale/explanation (not just bulleted list), relate to agent-specific concerns, provide actionable guidance

8. **Example Task Quality Review:** Verify all example tasks use actual infrastructure (empire user, 24.204.72.65 IP, actual service names), include command syntax, show expected outcomes

**Constraints:**
- Cannot validate guideline content appropriateness (only compliance with written guideline)
- Cannot detect tone/style consistency (formatting/structure validation only)
- Markdown validation is basic (only major formatting issues caught, subtle style issues missed)
- Guidelines may evolve (audit validates against current guideline version only)
- Different agent types may require guideline variations (audit may need rule adjustments per type)
- Examples must be provided by agent creator (audit validates format, not relevance)
- Cannot detect if guideline sections are merely template text not customized (requires manual review)

---

## Skill Area 7: Audit Report Generation & Remediation Guidance

**Purpose:** Generate comprehensive audit reports with specific remediation guidance for identified issues.

**Capabilities:**
- Detailed audit report generation (executive summary, findings by category, recommendations)
- Issue severity classification (critical: blocks deployment, major: coordination gap, minor: documentation quality)
- Remediation guidance generation (specific action items with examples)
- Compliance scoring (% complete for structural completeness, coordination, technical accuracy)
- Before/after documentation (show what needs to change with specific examples)
- Root cause analysis (why consistency issue exists, not just what is wrong)
- Impact assessment (how issue affects operational readiness)
- Prioritization guidance (which issues fix first for fastest deployment)
- Cross-file impact analysis (if Docker agent has gap, show which other agents affected)
- Tracking recommendations (suggest validation procedures to prevent future issues)

**Examples:**
1. **Pre-Deployment Audit Report:** Generate report for new agent showing: 100% structural completeness, 95% cross-agent coordination (missing 1 bidirectional reference), 100% technical accuracy, 2 minor guideline compliance issues. Remediation: add reference to Agent X in Reference Implementation (specific line numbers shown), update markdown formatting in Skill Area 3 (before/after examples provided)

2. **Quarterly Compliance Report:** Generate report for all 5 agents showing compliance scores: Docker 98%, Network 92%, Prometheus 96%, WireGuard 99%, Samba 100%. Identify Network agent needs 8 best practices added (currently 0), flag coordination gap between Network/Samba firewall documentation

3. **Emergency Validation After Change:** Generate focused report on Docker agent after emergency configuration change, highlighting: all sections present (structural 100%), port coordination verified (technical 100%), reference updates needed (coordination 85%), recommend adding deployment procedure to Docker Agent Skill Area 1 validation procedures

4. **Remediation Tracking:** Generate report showing: 15 issues identified, recommended priority (3 critical blocking deployment, 7 major affecting coordination, 5 minor documentation), estimated effort per fix, suggested implementation order

5. **Root Cause Analysis:** Report identifies "Network Agent has minimal Samba coordination (1 mention vs expected 8)" with root cause "Network Agent created before Samba Agent, not retroactively updated when Samba added". Remediation: add Network/Samba coordination section to Network Agent Reference Implementation with specific firewall rules (445/tcp, 137-138/udp)

6. **Impact Assessment:** Report shows "Samba agent coordination gap affects: Docker Agent (container deployment), Network Agent (firewall rules), Prometheus Agent (metrics), WireGuard Agent (remote access)". Recommends prioritizing Samba agent audit fixes over minor issues in other agents

7. **Preventive Recommendations:** Report suggests "Implement post-deployment audit automation: run Audit Agent checklist within 24 hours of new agent deployment, monthly compliance scans for all existing agents, quarterly deep audits"

8. **Compliance Trend Analysis:** Generate quarterly trend report showing compliance scores over time, identify if documentation quality improving/degrading, flag agents with declining coordination mentions

**Constraints:**
- Cannot fix issues automatically (only identify and recommend remediation)
- Report severity classification requires judgment (Audit Agent provides reasoning, human approval recommended)
- Root cause analysis is inferential (based on documentation patterns, not infrastructure inspection)
- Remediation effort estimates are approximations (actual time depends on agent complexity, documentation state)
- Cannot determine business impact (operational priority requires human decision)
- Report comprehensiveness limited to agent skills documentation (doesn't assess operational infrastructure)
- Impact assessment based on documented dependencies (if dependency not documented, impact may be missed)

---

## Diagnostic Workflow 1: New Agent Pre-Deployment Validation

**Problem:** New agent skills file created but needs validation before deployment to ensure it won't create operational blind spots or coordination gaps.

**Steps:**
1. Receive new agent skills file location/name (e.g., `/home/empire/gateway-mgmt/.agents/agents/phase-1-foundation/STORAGE_BACKUP_AGENT_SKILLS.md`)
2. Verify file exists and is readable
3. Check structural completeness: Overview present (≥100 words), Architecture Context present, Skill Areas present (5-9 expected), Diagnostic Workflows present (3-6 expected), Validation Checklist present (12+ items), Reference Implementation present
4. Count skill areas, confirm agent type-appropriate (5-9 range acceptable)
5. Verify cross-agent references: scan for mentions of Docker, Network, Prometheus, WireGuard, Samba (all applicable agents mentioned, bidirectional checked by validating other agents also mention new agent)
6. Check file paths: verify any mentioned paths follow `/usr/local/bin/`, `/etc/`, `/home/` conventions, no paths like `/tmp/` or custom locations
7. Validate ports: if any ports mentioned, cross-reference against known allocation (2222, 5000-5999, 8000-9999, 9090, 9093, 9100, 51820, 445, 137-138)
8. Check network addresses: verify any IPs mentioned fall in 24.204.72.64/26 range (24.204.72.65-24.204.72.126)
9. Verify guideline compliance: check markdown formatting (proper headings, code blocks), Skill Area structure (capabilities, examples, constraints sections), Diagnostic Workflow structure (steps, outcomes, prerequisites)
10. Generate pre-deployment report with findings, severity levels (critical blocks deployment, major needs fix, minor documentation)
11. Provide specific remediation: for each issue, show example text, exact line numbers, recommended changes with before/after examples
12. Clear for deployment only when: structural completeness 100%, cross-agent coordination 100%, port/network/path consistency verified, guideline compliance >95%

**Expected Outcomes:**
- Pre-deployment report generated with pass/fail recommendation
- All critical issues identified before agent goes live
- Remediation guidance provided with specific examples
- Existing agents flagged for updates (if new agent not yet referenced)
- No operational blind spots created by incomplete documentation

**Prerequisites:**
- New agent skills file must exist and be complete (not template/placeholder)
- All applicable agents identified (agent type, integration points known)
- Infrastructure topology known (network range, port allocations, file paths)
- SKILLS_MARKDOWN_GUIDELINE available for format validation
- Operator confirms new agent ready for deployment (not experimental)

---

## Diagnostic Workflow 2: Cross-Agent Coordination Gap Detection & Resolution

**Problem:** Agent documentation exists but coordination between agents incomplete (A mentions B, but B doesn't mention A), creating operational confusion and integration risks.

**Steps:**
1. Receive report of suspected coordination gap or run scheduled audit
2. Identify source agent (A) and referenced agent (B)
3. Scan Agent A Reference Implementation for mentions of Agent B (search for "AGENT_B_SKILLS", "Coordinated with B", direct B references)
4. If Agent B mentioned in A: scan Agent B Reference Implementation for reverse mention of A
5. If reverse mention not found: gap identified
6. Determine gap type: one-way mention only (A→B without B→A), or bidirectional missing
7. Assess if gap is justified (some agents may not need reverse reference if relationship is truly unidirectional)
8. If gap unjustified: identify what Agent B should document about Agent A
9. Example: if Docker mentions Samba (containers for file sharing) but Samba doesn't mention Docker (container deployment), gap exists
10. Generate remediation: specific text to add to Agent B Reference Implementation, example coordination workflow, dependencies to document
11. Flag all related agents (if Samba-Docker gap found, check if Network agent documents both, Prometheus coordination, WireGuard coordination)
12. Create tracking item: coordination gap fix, estimated 15-30 minutes effort per agent, deploy within next maintenance window

**Expected Outcomes:**
- Coordination gap clearly identified with specific agents and missing references
- Remediation text provided ready for copy/paste into affected agents
- All related agents scanned for cascading gaps
- Bidirectional coordination verified after remediation
- No documentation silos between agents

**Prerequisites:**
- Both agents in question must exist and be deployed
- Agent Reference Implementation sections must be standardized (audit locates them predictably)
- Gap severity must be assessed (not all unidirectional relationships are gaps)
- Operator confirms gap needs fixing (audit may flag false positives)

---

## Diagnostic Workflow 3: Technical Consistency Audit & Remediation

**Problem:** Network addresses, port numbers, or file paths documented inconsistently across agents, creating operational risk (e.g., one agent says 24.204.72.65, another says 24.204.72.65 for Gateway).

**Steps:**
1. Receive technical consistency audit request (e.g., "verify port allocations consistent")
2. Identify dimension to audit (network addresses, ports, file paths, time intervals, storage specs)
3. Search all agent skills files for target pattern (e.g., for port audit, search for port number mentions)
4. Collect all found instances with context (which agent mentioned port, in which section, what context)
5. Normalize findings (e.g., "8000-8999" vs "8000-9999" vs "dev ports 8000-9999" all normalized to same format)
6. Identify inconsistencies (port ranges documented differently, IPs differ, paths not matching conventions)
7. Prioritize fixes: critical (operational impact if ignored), major (confusion but workarounds exist), minor (documentation quality)
8. Example: if Network Agent says "dev ports 8000-9999" but Docker Agent says "dev ports 8000-8999", critical inconsistency (512 port difference)
9. Generate remediation: identify source of truth (Network Agent port allocation is authoritative), show all agents that need updates, provide correct text
10. Cross-reference: if fixing port allocation, verify Prometheus monitoring covers correct port ranges, WireGuard access rules updated, Samba doesn't use conflicting ports
11. Create remediation task with specific agents, line numbers, before/after text examples
12. Verify all instances updated (search again post-fix to confirm no stale documentation)

**Expected Outcomes:**
- All technical inconsistencies identified and classified by severity
- Single source of truth established (Network Agent for ports, Infrastructure topology document for IPs)
- All affected agents updated with correct information
- Post-fix verification confirms no stale documentation remains
- Operational team has confidence in documented infrastructure details

**Prerequisites:**
- Dimension being audited must be critical to operations (don't audit low-impact details)
- Source of truth must be identified (Network Agent for ports, Infrastructure doc for topology)
- All affected agents must be available for review (can't audit partial ecosystem)
- Operator must confirm inconsistency is operational risk (audit flags all variations, operator confirms which matter)

---

## Diagnostic Workflow 4: Guideline Compliance & Format Standardization

**Problem:** Agent skills file exists but doesn't follow SKILLS_MARKDOWN_GUIDELINE format, making it harder for operators to find information, inconsistent with other agents.

**Steps:**
1. Receive agent skills file for compliance audit
2. Load SKILLS_MARKDOWN_GUIDELINE as reference standard
3. Check major sections present: Overview, Architecture Context, 5-9 Skill Areas, Diagnostic Workflows (3-6), Validation Checklist, Reference Implementation
4. For each section, verify structure matches guideline: headings at correct level, content organization follows pattern
5. For Skill Areas: verify each includes "Capabilities:", "Examples:", "Constraints:" subsections as guideline specifies
6. For Diagnostic Workflows: verify each includes title, problem statement, numbered steps, expected outcomes, prerequisites
7. For Validation Checklist: verify items are pre-deployment checks (not ongoing procedures), measurable (not vague), checkbox format [ ]
8. For Best Practices: verify each includes specific recommendation with rationale (not generic advice like "be careful")
9. Check markdown: proper heading levels (# main, ## sections, ### subsections), code blocks have language specifiers (```bash), tables properly formatted
10. For examples and code: verify they're concrete/specific to infrastructure (not theoretical), actual executable commands, realistic scenarios
11. Generate compliance report: % completion per section, specific format issues with line numbers, before/after examples for fixing
12. Provide remediation: exact markdown to fix each issue, how to reorganize content to match guideline, new structure recommended

**Expected Outcomes:**
- Compliance score generated (% adherence to guideline)
- All format inconsistencies identified with specific locations
- Remediation guidance provided with exact text/structure examples
- Agent updated to match guideline standardization
- Operator can locate information consistent with other agents

**Prerequisites:**
- Agent skills file must be substantially complete (not template)
- SKILLS_MARKDOWN_GUIDELINE must be current and available
- Format issues must be significant (don't flag minor style variations)
- Operator confirms compliance improvements valued (not make-work audit)

---

## Validation Checklist

**Pre-Deployment Validation:**
- [ ] New agent skills file exists and is readable in .agents/skills directory
- [ ] Structural completeness verified: Overview (≥100 words), Architecture Context, 5-9 Skill Areas, 3-6 Diagnostic Workflows, Validation Checklist (12+ items), Reference Implementation present
- [ ] Cross-agent coordination verified: all applicable agents mentioned in Reference Implementation, bidirectional confirmation completed
- [ ] File paths validated: any mentioned paths follow /usr/local/bin/, /etc/, /home/ conventions, no unsafe paths like /tmp/
- [ ] Port numbers verified: any mentioned ports match known allocation (2222, 5000-5999, 8000-9999, 9090, 9093, 9100, 51820, 445, 137-138)
- [ ] Network addresses validated: all IPs fall within 24.204.72.64/26 range (24.204.72.65-24.204.72.126)
- [ ] Guideline compliance >95%: structure, markdown formatting, skill area organization matches SKILLS_MARKDOWN_GUIDELINE
- [ ] Example tasks verified: concrete, infrastructure-specific, executable commands, realistic scenarios documented
- [ ] Constraints documented: 6+ for simple agents, 20+ for complex agents, safety limits clear
- [ ] Best practices included: 8-12 recommendations with rationale, agent-specific guidance
- [ ] All critical issues remediated: no blocking items remain
- [ ] Bidirectional coordination updates complete: all existing agents updated with new agent references
- [ ] Pre-deployment report generated: pass/fail recommendation, severity levels, remediation guidance

**Quarterly Compliance Audit:**
- [ ] All 5 operational agents reviewed (Docker, Network, Prometheus, WireGuard, Samba)
- [ ] Structural completeness verified for each (Overview, Architecture, Skills, Workflows, Checklist, Reference Implementation)
- [ ] Skill area counts confirmed: Docker 6, Network 5, Prometheus 6, WireGuard 9, Samba 7
- [ ] Diagnostic workflow counts confirmed: each agent has 3-6 workflows
- [ ] Validation checklist items counted: 12+ for all agents
- [ ] Cross-agent coordination matrix verified: 5x5 bidirectional references complete
- [ ] Network topology consistency: 24.204.72.65 (Gateway) referenced consistently, all node addresses verified
- [ ] Port allocations verified: no collisions, all ranges documented (2222, 5000-5999, 8000-9999, 9090, 9093, 9100, 51820, 445, 137-138)
- [ ] File paths consistent: exporter scripts at /usr/local/bin/, configs at /etc/
- [ ] Time intervals synchronized: 15-second Prometheus scrape, 10-second exporter timeout, 30-day retention
- [ ] Constraint documentation present: 91 total constraints across all agents
- [ ] Best practices documented: 39 total recommendations across all agents
- [ ] Technical accuracy spot-checked: 10+ randomly selected claims verified
- [ ] Compliance scores calculated: individual agent scores and ecosystem overall score
- [ ] Trend analysis completed: scores compared to previous audit cycle
- [ ] Quarterly compliance report generated with findings and remediation priorities

**Coordination Gap Resolution:**
- [ ] Source and target agents identified (which agent mentions which)
- [ ] Bidirectional coordination verified (both directions checked)
- [ ] Gap severity assessed (operational impact, confusion risk)
- [ ] Remediation text generated (ready for copy/paste)
- [ ] All related agents scanned for cascading gaps
- [ ] Target agent updated with missing reference
- [ ] Reverse coordination verified (target agent now mentions source)
- [ ] All other agents checked for related coordination (firewall, monitoring, jumpbox access)
- [ ] Cross-agent coordination matrix re-validated after fix
- [ ] Coordination gap resolution documented in audit report

**Technical Consistency Remediation:**
- [ ] Target dimension identified (ports, IPs, paths, intervals, storage)
- [ ] All instances found and catalogued (which agents, which sections)
- [ ] Inconsistencies normalized and classified (critical, major, minor)
- [ ] Source of truth confirmed (Network Agent for ports, Infrastructure doc for IPs)
- [ ] Remediation text prepared (all agents to update identified)
- [ ] All affected agents updated (line numbers, before/after examples documented)
- [ ] Post-fix verification completed (search repeated to confirm all instances updated)
- [ ] Related technical details cross-checked (if ports fixed, verify monitoring/firewall rules match)
- [ ] Operational team notified of changes
- [ ] Technical consistency resolution documented with version/date

---

## Best Practices

1. **Audit Frequency:** Run weekly lightweight structural checks (sections present, counts correct), monthly cross-agent coordination audit, quarterly comprehensive audit (all dimensions). Catch issues early before they cascade into operational problems.

2. **Automated Baseline Collection:** Maintain automated collection of structural metrics (skill area counts, workflow counts, constraint counts, port numbers found) to track trends, detect anomalies immediately when someone deletes a section.

3. **Source of Truth Designation:** Clearly designate Network Agent as authoritative for port allocations, Infrastructure documentation as authoritative for network topology. When inconsistencies found, always default to source of truth, not majority vote.

4. **Cross-Agent Relationship Mapping:** Maintain explicit dependency graph (Docker depends on Network, Samba depends on Docker+Network+Prometheus+WireGuard, etc.). Use this to predict impact of changes before making them, audit for missing dependencies proactively.

5. **Template for New Agents:** Don't create new agents from scratch. Start with copy of similar existing agent (WireGuard as template for VPN agents, Samba as template for storage agents, etc.), modify structure/content, then run pre-deployment validation immediately.

6. **Enforcement at Merge:** Implement pre-merge checks in version control: new agents can't merge without Audit Agent pre-deployment validation report showing pass, existing agents can't merge if audit shows coordination gaps or critical inconsistencies.

7. **Guideline Evolution Process:** When SKILLS_MARKDOWN_GUIDELINE changes, run compliance audit on all agents against new guideline, generate remediation for each, schedule bulk update rather than one-off changes. Keep ecosystem synchronized.

8. **Operator Training:** Train ops team to run Audit Agent workflows when adding features (new agent skills needed), modifying infrastructure (port changes), or troubleshooting (check if coordination gap exists). Make audits part of standard procedures.

9. **Root Cause Analysis:** When audit finds issue, don't just fix symptom. Example: if port inconsistency found, ask "how did this happen?" (was guideline unclear? Were updates missed? Was new agent created without coordination check?). Fix root cause to prevent recurrence.

10. **Capacity Planning in Constraints:** As infrastructure scales, audit constraint documentation to ensure limits still apply (e.g., "max 10 concurrent SMB users" may need adjustment for 100-person organization). Use audit to identify when constraints become outdated.

11. **Coordination Pattern Library:** Maintain documented examples of common coordination patterns (Docker+Network integration, Prometheus exporter scripts, WireGuard jumpbox access, etc.). Reference these patterns when creating new agents, reduce inconsistency.

12. **Audit Report Automation:** Automate audit report generation to JSON/structured format, enable dashboard/alerting (if compliance score drops, alert ops team), track metrics over time, identify trending issues before they become critical.

---

## Reference Implementation

### Coordinated with Docker Agent
The Audit & Validation Agent validates Docker Agent skills documentation:
- **Structural validation:** Ensures Docker Agent maintains 6 skill areas, 5 diagnostic workflows, 12+ validation items
- **Coordination check:** Verifies Docker Agent documents Network (firewall), Prometheus (metrics), WireGuard (jumpbox), Samba (container sharing) in Reference Implementation
- **Port validation:** Confirms Docker ports (2222, 5000-5999, 8000-9999, 2377, 7946, 4789) documented consistently across all agents
- **Service verification:** Ensures all Docker services referenced in Prometheus (container metrics), Network (firewall rules), WireGuard (jumpbox networking) coordinate with Docker Agent documentation
- **Example:** Pre-deployment validation for updated Docker Agent: runs through 12-point checklist, confirms new service documentation includes skill areas, validates all new ports in Network Agent firewall matrix, checks Prometheus labels added for new service metrics

### Coordinated with Network Agent
The Audit & Validation Agent validates Network Agent skills documentation:
- **Firewall coordination matrix:** Verifies Network Agent maintains authoritative port allocation list (Docker 2222/5000-5999/8000-9999/2377/7946/4789, Prometheus 9090/9093/9100, WireGuard 51820/udp, Samba 445/137-138)
- **Port consistency audit:** Confirms all other agents reference Network Agent port documentation, no agents document conflicting port allocations
- **Topology documentation:** Validates network topology (24.204.72.65 Gateway, 24.204.72.66 SpaceBase) consistent across all agents
- **Firewall rule coordination:** Ensures Network Agent documents firewall rules coordinated with Docker (service ports), Prometheus (monitoring access), WireGuard (VPN), Samba (SMB access)
- **Example:** Technical consistency audit finds Docker Agent mentions "dev ports 8000-8999" but Network Agent says "8000-9999". Audit identifies Network Agent as source of truth, generates remediation to update Docker Agent, verifies all agents use correct range after fix

### Coordinated with Prometheus Agent
The Audit & Validation Agent validates Prometheus Agent skills documentation:
- **Exporter script paths:** Verifies Prometheus Agent and other agents reference exporter scripts consistently (/usr/local/bin/wireguard-exporter.sh, /usr/local/bin/samba-exporter.sh)
- **Scrape interval consistency:** Confirms all agents document Prometheus scrape interval as 15 seconds (not varying documentation)
- **Metric retention:** Validates Prometheus retention policy (30 days) documented consistently
- **Monitoring coordination:** Ensures Prometheus Agent documents monitoring for all other agents (Docker container metrics, Network firewall metrics, WireGuard peer metrics, Samba connection metrics)
- **Example:** Quarterly compliance audit confirms Prometheus Agent has 6 skill areas, 3 diagnostic workflows, 14 validation items, and documents custom exporters for WireGuard and Samba with correct script paths

### Coordinated with WireGuard Agent
The Audit & Validation Agent validates WireGuard Agent skills documentation:
- **VPN port documentation:** Verifies WireGuard 51820/udp port documented consistently across WireGuard and Network agents
- **Peer topology:** Validates WireGuard peer addresses (24.204.72.67 hyperdrive, 24.204.72.68 Laboratory) consistent with infrastructure documentation
- **Jumpbox coordination:** Confirms WireGuard documents SSH jumpbox coordination with Docker Agent (container networking), Network Agent (firewall port 2222)
- **Exporter coordination:** Validates WireGuard exporter script referenced in both WireGuard Agent (management procedures) and Prometheus Agent (metrics collection)
- **Example:** Pre-deployment validation for WireGuard Agent enhancement: checks new skill areas, verifies new peer references added to all affected agents, confirms firewall rules for new peer documented in Network Agent

### Coordinated with Samba Agent
The Audit & Validation Agent validates Samba Agent skills documentation:
- **Container coordination:** Verifies Samba Agent documents Docker container deployment (24.204.72.65, 24.204.72.66), coordinates with Docker Agent regarding container orchestration
- **Port documentation:** Confirms Samba ports (445/tcp, 137-138/udp) documented in Samba Agent and firewall rules in Network Agent
- **Remote access coordination:** Validates Samba Agent documents jumpbox access (SSH tunneling via WireGuard), coordinates with WireGuard Agent for peer access procedures
- **Metrics integration:** Ensures Samba Agent documents custom exporter script (/usr/local/bin/samba-exporter.sh), references Prometheus Agent for metrics collection
- **Example:** Coordination gap detection finds Samba Agent mentions Docker (container deployment) but Docker Agent doesn't mention Samba. Audit generates remediation: add Samba reference to Docker Agent Reference Implementation with specific container coordination details

### Coordinated with SKILLS_MARKDOWN_GUIDELINE
The Audit & Validation Agent validates all agents against SKILLS_MARKDOWN_GUIDELINE:
- **Structure enforcement:** Ensures all agents follow guideline structure (Overview, Architecture Context, Skill Areas, Workflows, Checklist, Reference Implementation)
- **Formatting validation:** Confirms markdown formatting consistent (heading levels, code blocks with language, table structure)
- **Skill area patterns:** Validates each skill area includes Capabilities, Examples, Constraints sections as guideline specifies
- **Multi-agent coordination patterns:** Ensures agents use coordination patterns documented in guideline (e.g., "Coordinated with X Agent:" format)
- **Example:** New Storage Agent pre-deployment: audit verifies structure matches guideline template, formats conform to standards, examples are concrete/infrastructure-specific, constraints documented at appropriate depth

### Example Coordination Workflow: New Agent Deployment

When new Storage Agent created for NAS management:

1. **Pre-Deployment Validation (Audit Agent Skill 1):** Audit Agent receives Storage Agent skills file, runs 12-point checklist (structure, coordination, ports, paths, guideline compliance), generates report with any issues found

2. **Structural Completeness (Audit Agent Skill 2):** Audit confirms Storage Agent has all required sections (Overview, Architecture, 5-7 Skill Areas, 3-5 Workflows, 12+ Validation items)

3. **Cross-Agent Coordination (Audit Agent Skill 3):** Audit verifies Storage Agent mentions Docker (container deployment), Network (NAS port firewall rules), Prometheus (storage metrics), and flag gap: Storage Agent is new so other agents don't mention it yet. Generate remediation tasks to add Storage references to all 4 existing agents

4. **Technical Consistency (Audit Agent Skill 4):** Audit checks Storage Agent doesn't introduce new ports conflicting with existing allocation, NAS IP falls in 24.204.72.64/26 range, config paths follow /etc/storage/ conventions

5. **Constraints Documentation (Audit Agent Skill 5):** Audit verifies Storage Agent documents capacity limits (e.g., "8TB NAS maximum"), concurrent connection limits, performance constraints

6. **Guideline Compliance (Audit Agent Skill 6):** Audit confirms Storage Agent markdown formatting matches guideline, skill areas follow required structure, examples are concrete

7. **Report & Remediation (Audit Agent Skill 7):** Audit generates comprehensive pre-deployment report: 100% structural compliance, coordination gaps identified (4 agents need updates), technical accuracy verified, 2 minor guideline improvements recommended. Provides exact remediation text for each issue.

8. **Deployment Gate:** Storage Agent can be deployed only when audit report shows all critical issues resolved, major issues have remediation planned, pre-deployment checklist items >90% complete

---

## Known Limitations & Gotchas

1. **Documentation vs. Reality:** Audit Agent validates documentation consistency, not infrastructure reality. A technically correct config in production may have inconsistent documentation, or vice versa. Manual infrastructure verification still required.

2. **False Positive Coordination Gaps:** Audit Agent may flag "gap" when relationship is intentionally one-way (e.g., Network Agent mentions Docker firewall but Docker doesn't mention Network rules). Operator must confirm gap is real vs. intentional asymmetry.

3. **Guideline Drift:** If SKILLS_MARKDOWN_GUIDELINE changes frequently, agents may be documented against different versions of guideline. Audit must track which guideline version used, not just current version compliance.

4. **Scalability Concerns:** With 5+ agents, audit complexity grows. 10 agents may require more sophisticated tooling (automated parsing, dashboards) than simple text search. Current audit procedures scale to ~10 agents, then need architecture review.

5. **Context-Dependent Issues:** Some documentation issues only matter in certain contexts (e.g., if Samba never actually used in deployment, missing Samba-Docker coordination isn't operational risk). Audit can flag but can't determine operational impact.

6. **Operator Override Risk:** If audit report recommends remediation but operator disagrees with recommendation, audit doesn't enforce anything. Audit is advisory, not mandatory. Weak teams may ignore audit reports, reducing value.

7. **Storage Specification Precision:** Time intervals and storage limits documented with floating point (15 seconds, 2GB, 30 days) but actual infrastructure may have slight variations (14.9 seconds scrape in practice). Audit validates documented values match, not if actual is perfect.

8. **Port Allocation Rigidity:** Current port allocation scheme (2222, 5000-5999, etc.) works for small infrastructure but may become constraint at scale. Audit enforces current scheme, doesn't help when scheme needs fundamental redesign.

9. **Exporter Script Versioning:** Audit validates /usr/local/bin/wireguard-exporter.sh path is mentioned, but not if script version is compatible with current Prometheus/WireGuard versions. Script updates may require coordination docs also updated.

10. **Manual Remediation Burden:** Audit identifies issues and provides remediation guidance, but humans must implement fixes. High-frequency audits + slow remediation = audit reports pile up faster than fixes applied.

---

**Last Updated:** September 16, 2026  
**Version:** 1.0 - Initial Release  
**Status:** PRODUCTION READY

