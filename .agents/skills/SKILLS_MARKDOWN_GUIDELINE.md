# AI Agent Skills Markdown Guideline

## Purpose

This guideline provides a standard structure and format for writing AI agent skills markdown files. These files define what capabilities an agent has, how to use them, constraints, and example workflows. A well-written skills file enables AI agents to understand their responsibilities and operate effectively within defined boundaries.

---

## File Structure

### 1. Title & Overview Section

**Purpose:** Establish the agent's identity and scope at a glance.

**Format:**
```markdown
# [Agent Type] Agent Skills

## Overview
[2-3 sentence summary of the agent's domain and primary responsibilities]
```

**Guidelines:**
- Use descriptive agent names: `Network Management Agent`, `Docker Orchestration Agent`, etc.
- Overview should answer: "What does this agent do?"
- Keep overview concise but complete

**Example:**
```markdown
# Network Management Agent Skills

## Overview
This document defines the capabilities and responsibilities of the Network Management Agent 
for the gateway-mgmt infrastructure. The agent manages on-premise network infrastructure 
including firewall rules, routing, DNS, VPN connectivity, and monitoring.
```

---

### 2. Architecture & Context Section

**Purpose:** Provide essential background so the agent understands the environment it operates in.

**Format:**
```markdown
## [Domain] Architecture Context

### Core Infrastructure
- **[Component Name]**: [Purpose/Details]
- **[Component Name]**: [Purpose/Details]

### Key Devices & Services
- [Service 1]
- [Service 2]

### Authentication
- [Auth method and requirements]
```

**Guidelines:**
- Include IPs, network ranges, hostnames, and other infrastructure constants
- List all external services, databases, and integrations the agent interacts with
- Document authentication methods and security requirements
- Use bulleted lists with bold labels for clarity
- This section answers: "What infrastructure exists?" and "How do I access it?"

**Example:**
```markdown
## Network Architecture Context

### Core Infrastructure
- **Gateway IP**: 24.204.72.65 (when WireGuard is active)
- **Network Range**: 24.204.72.64/26
- **VPN Architecture**: Local WireGuard → Mullvad VPN (chained)
- **DNS**: Pi-hole at gateway
- **Monitoring**: Prometheus + node_exporter
```

---

### 3. Skill Areas Section

**Purpose:** Define discrete, actionable capabilities grouped by function.

**Format for Each Skill:**
```markdown
### [Number]. [Skill Name] Skill

**Responsibilities:**
- [High-level duty 1]
- [High-level duty 2]

**Capabilities:**
- [Concrete action 1]
- [Concrete action 2]
- [Can query/check X]
- [Can modify/create Y]

**Example Tasks:**
- `[Example command or scenario]`
- [Describe what agent should do]
- [Another example]

**Constraints:**
- [Limitation or safety rule 1]
- [Limitation or safety rule 2]
```

**Optional Subsections (include only if relevant):**
- **Key Interfaces/Endpoints**: For skills that interact with specific APIs, services, or system interfaces
- **Environment Variables/Config**: For skills requiring configuration knowledge
- **Error Handling**: For skills where common failures need explicit handling guidance

**Guidelines:**

- **Number skills sequentially** (1, 2, 3...) for easy reference
- **Responsibilities** are strategic/high-level (what should the agent do?)
- **Capabilities** are tactical/low-level (how does it do it? what commands/APIs?)
- **Example Tasks** bridge the gap between capabilities and real-world use (concrete scenarios)
- **Constraints** establish safety boundaries and best practices with specific, testable rules:
  - "Verify service status via `systemctl status` before making configuration changes"
  - "Require explicit user confirmation before deleting resources with `-f` or `--force` flags"
  - "Check current firewall state with `ufw status` before adding rules; report conflicts"
- Use backticks for commands, API calls, or file paths
- Keep each skill focused on one domain (firewall skill ≠ routing skill, even if both touch networking)

**Skill Quality Checklist:**
- ✓ Does it have clear responsibilities?
- ✓ Can the agent determine if it has the capability to handle a request?
- ✓ Are example tasks realistic and specific?
- ✓ Are constraints clear enough to prevent misuse?
- ✓ Would an AI understand how to execute this?

**Example Skill:**
```markdown
### 1. Firewall Management Skill

**Responsibilities:**
- Analyze and modify firewall rules (UFW on Linux systems)
- Diagnose firewall-blocking issues
- Recommend rule changes for connectivity problems

**Capabilities:**
- Read UFW status and rules
- Add/remove/modify UFW rules with source/destination/port/protocol specificity
- Query iptables for deeper inspection
- Test rule effectiveness with connectivity checks

**Example Tasks:**
- Allow traffic from 10.0.0.2 to port 9100: `sudo ufw allow from 24.204.72.67 to any port 9100 proto tcp`
- Diagnose "port X not accessible from Y" issues
- Review rules blocking expected traffic

**Constraints:**
- No changes without analysis and recommendation first
- Major rule deletions require confirmation
- All changes must be logged for audit trail
```

---

### 4. Diagnostic Workflows Section

**Purpose:** Document complex, multi-step problem-solving approaches the agent should use.

**Format:**
```markdown
## Diagnostic Workflows

### [Workflow Name]
1. **Symptom**: [What the user observes]
2. **Steps**:
   - [Step 1 with tool/command]
   - [Step 2 - what to check]
   - [Step 3 - analyze results]
   - [Step 4 - recommend solution]
```

**Guidelines:**
- Use workflows for complex troubleshooting paths involving 3+ steps
- Number steps sequentially for clarity
- Each step should include: the action to take, what to check, and what to do with the result
- Steps should flow logically (e.g., check prerequisites before attempting fixes)
- Workflows typically involve multiple skills working together
- Keep workflows to 4-8 steps (avoid overwhelming); break complex troubleshooting into multiple workflows
- Use conditional language where branches exist: "If X is true, then check Y; if false, check Z"

**Example Workflow:**
```markdown
### Connectivity Troubleshooting
1. **Symptom**: Host A cannot reach Host B on the network
2. **Steps**:
   - Ping Host B from Host A (check if reachable)
   - Check routing table on Host A (is there a route?)
   - Check firewall rules on both sides
   - Verify VPN status if cross-VPN communication
   - Recommend fixes (route, firewall rule, service restart)
```

---

## Writing Best Practices

### Language & Tone
- **Be specific**: Use actual commands, IPs, and service names
- **Be concise**: Avoid lengthy explanations; use bullet points
- **Be actionable**: Each line should guide concrete action
- **Avoid ambiguity**: Don't assume agent knowledge; define terms

### Structure Rules
1. **Headers**: Use descriptive H2-H4 headers (avoid H1 except title)
2. **Lists**: Use bullets for capabilities/constraints; numbers for steps
3. **Code**: Wrap commands and paths in backticks (e.g., `` `ufw allow 22/tcp` ``, `` `/etc/wireguard/` ``)
4. **Bold**: Use bold only for section labels (e.g., `**Responsibilities:**`, `**Example Tasks:**`)
5. **Terminology**: Define technical terms the first time they appear, or reference the Architecture Context section

### Anti-Patterns to Avoid
- ❌ Vague responsibilities ("manage things")
- ❌ Capabilities without examples ("can query systems")
- ❌ Constraints that are just rules ("don't be bad")
- ❌ Missing authentication details ("log in as needed")
- ❌ Inconsistent formatting (sometimes bullets, sometimes paragraphs)
- ❌ Skills that overlap or duplicate (consolidate related skills)

### Best Practices
- ✓ Update skills file immediately when agent capabilities change
- ✓ Include last-updated date at the top of the file for version tracking
- ✓ Use the skills file to train/test the agent with example queries
- ✓ Keep all essential, operational information in this file; link to external docs only for deep dives
- ✓ Group related skills together (e.g., all networking skills in sequence)
- ✓ Run through each workflow yourself to verify steps are accurate and complete

---

## Template

Use this template to start a new agent skills file:

```markdown
# [Domain] Agent Skills

## Overview
[2-3 sentences: what does this agent do and in what context?]

## [Domain] Architecture Context

### Core Infrastructure
- **[Item]**: [Details]

### Key External Services & Integration Points
- [Service Name]: [purpose and how agent interacts with it]
- [Service Name]: [purpose and how agent interacts with it]

### Authentication & Access
- [Auth method and how to authenticate]
- [Key credential locations and permission requirements]

---

## Skill Areas

### 1. [Skill Name] Skill

**Responsibilities:**
- [Strategic duty]
- [Strategic duty]

**Capabilities:**
- [Tactical action]
- [Tactical action]

**Example Tasks:**
- [Concrete scenario]
- [Concrete scenario]

**Constraints:**
- [Safety/best-practice rule]
- [Safety/best-practice rule]

---

## Diagnostic Workflows

### [Common Problem] Troubleshooting
1. **Symptom**: [What user observes]
2. **Steps**:
   - [Investigation step]
   - [Analysis step]
   - [Recommendation step]
```

---

## Validation Checklist

Before publishing a skills file, verify:

- [ ] Title and overview clearly define agent scope
- [ ] Architecture section includes all infrastructure details needed
- [ ] Each skill has responsibilities, capabilities, examples, and constraints
- [ ] Examples use real commands/paths (not placeholders)
- [ ] Constraints are specific, not vague
- [ ] Workflows cover common troubleshooting scenarios
- [ ] No skill overlaps significantly with another
- [ ] Formatting is consistent throughout (bullets, bold, code blocks)
- [ ] Technical terms are defined or explained
- [ ] A new agent could understand the role from reading this alone
- [ ] Cross-agent dependencies are documented in both agents (bidirectional)

---

## Multi-Agent Coordination Patterns

When agents depend on each other's outputs or must coordinate actions, follow these patterns:

### 1. Dependency Documentation
When **Agent A** depends on **Agent B**'s outputs:
- **In Agent A's skills file**: Add "Coordination with Agent B" section in the relevant Skill Area
- **In Agent B's skills file**: Add reference in Reference Implementation section linking to Agent A
- **In both files**: Use consistent language for the dependency ("coordinated with", "verify with")

### 2. Integration Point Specification
Document at the boundary between agents:
- **Data Format**: Specify exact format of exchanged data (port numbers, config file format, metric names)
- **Timing**: Document synchronization requirements (e.g., "before Agent B runs", "every 15 seconds")
- **Validation**: Include validation steps to confirm integration is working
- **Failure Handling**: Document what to do if the other agent's output is unavailable or malformed

### 3. Reference Implementation Section
Each skills file should include examples of:
- Links to coordinating agent skills files
- Live configuration files showing the actual coordination
- Step-by-step workflows for multi-agent operations
- Cross-references to prerequisite agent skills

### 4. Constraint Documentation
When constraining actions based on another agent's state:
- Use phrases like "Coordinate with Agent X before [action]"
- Use phrases like "Verify Agent X has completed [prerequisite skill]"
- Specify exact validation commands: "Run `check_command` from Agent X to verify"

### Example: Network & Docker Coordination
If Network Agent manages firewall and Docker Agent deploys services:
1. **In NETWORK_AGENT_SKILLS.md**: "Firewall Rule Coordination Points" section lists all Docker service ports
2. **In DOCKER_AGENT_SKILLS.md**: "Constraints" section states "Coordinate with Network Agent for firewall rules"
3. **In DOCKER_AGENT_SKILLS.md**: "Reference Implementation" links to NETWORK_AGENT_SKILLS.md with specific port references
4. **Validation**: Both agents confirm firewall rules allow expected traffic (test with `curl`, `nc`)

---

## Validation Checklist (Revised)

---

## Reference Implementation

**Live Examples:**
- `AUDIT_VALIDATION_AGENT_SKILLS.md` - Quality control agent with 7 skills ensuring documentation consistency
- `NETWORK_AGENT_SKILLS.md` - Comprehensive reference implementation with multiple skills and workflows
- `SAMBA_AGENT_SKILLS.md` - Comprehensive multi-agent coordination with 7 skill areas and diagnostic workflows

**When implementing a new skills file:**
1. Start with the template provided in this guideline
2. Review `NETWORK_AGENT_SKILLS.md` for style and structure patterns
3. Use the Validation Checklist before finalizing
4. Have a team member review for clarity and completeness

---

## Questions to Guide Writing

When defining a new skill, ask:

1. **What is this skill for?** (Responsibility)
2. **What can the agent actually do?** (Capability)
3. **When would this be used?** (Example Task)
4. **When should it NOT do something?** (Constraint)
5. **What could go wrong?** (Error Constraints)
6. **What should the agent verify first?** (Pre-condition Constraints)

Answer these for each skill, and you'll have a clear, well-scoped skills file.
