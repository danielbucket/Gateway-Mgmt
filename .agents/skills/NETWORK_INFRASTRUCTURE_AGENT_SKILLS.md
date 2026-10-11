# NETWORK INFRASTRUCTURE AGENT SKILLS

> ⚠️ **Deprecated mirror file**.
> Canonical source: `.agents/agents/operational/infrastructure/NETWORK_INFRASTRUCTURE_AGENT_SKILLS.md`. Update and reference the canonical file only.

**Agent Purpose:**  
Serve as the authoritative source of truth for all infrastructure topology, node addressing, and service-to-IP mappings. This agent ensures consistent documentation of network infrastructure across all operational agents, enables seamless IP scheme migrations, and prevents addressing inconsistencies that could compromise system reliability.

**Primary Responsibilities:**
- Maintain authoritative infrastructure topology documentation
- Document node IP allocations and role assignments
- Map services to infrastructure components
- Coordinate IP scheme changes across all agents
- Enable infrastructure scaling and multi-region expansion
- Provide single source of truth for all addressing decisions
- Validate infrastructure consistency across operational agents
- Document failover and redundancy topology
- Plan future infrastructure growth

---

## Architecture & Context

### Current Infrastructure Topology (24.204.72.64/26)

**Network Range:** 24.204.72.64/26 (Public IP Address Space)
- **Network Address:** 24.204.72.64
- **Usable Host Range:** 24.204.72.65 - 24.204.72.126
- **Broadcast Address:** 24.204.72.127
- **Total Hosts:** 64 (62 usable)
- **Subnet Mask:** 255.255.255.192
- **CIDR Notation:** /26

**Node Allocations:**

| Node Name | IP Address | Role | Services | Status |
|---|---|---|---|---|
| Gateway | 24.204.72.65 | Primary manager | Docker Swarm Manager, Prometheus, Samba Server 1 | Primary |
| SpaceBase | 24.204.72.66 | Secondary worker | Docker Swarm Worker, Samba Server 2 | Redundant |
| Hyperdrive | 24.204.72.67 | VPN Peer | WireGuard Peer, External Access | Secondary |
| Laboratory | 24.204.72.68 | VPN Peer | WireGuard Peer, External Access | Secondary |

**Service Port Allocations (All nodes):**
- Docker Jumpbox: 2222/tcp (external-facing SSH)
- Docker Production: 5000-5999/tcp
- Docker Development: 8000-9999/tcp
- Docker Swarm: 2377/tcp (manager), 7946/tcp+udp (discovery), 4789/udp (overlay)
- Prometheus: 9090/tcp (UI/API), 9093/tcp (Alertmanager), 9100/tcp (node_exporter)
- WireGuard VPN: 51820/udp
- Samba/SMB: 445/tcp (SMB protocol), 137-138/udp (NetBIOS)

**Reserved Addresses for Future Use:**
- 24.204.72.69 - 24.204.72.75: Reserved for expansion nodes (7 addresses)
- 24.204.72.76 - 24.204.72.85: Reserved for service VIPs/load balancers (10 addresses)
- 24.204.72.86 - 24.204.72.126: Reserved for future services/nodes (41 addresses)

### Integration Points

| Integration | Purpose | Key Coordination |
|---|---|---|
| **DOCKER_AGENT_SKILLS** | Container orchestration on infrastructure | Validates node IPs, swarm topology |
| **NETWORK_AGENT_SKILLS** | Firewall rules for infrastructure nodes | Coordinates with Network Infrastructure for IP ranges |
| **PROMETHEUS_AGENT_SKILLS** | Metrics collection from all infrastructure nodes | References node IPs for scrape targets |
| **WIREGUARD_AGENT_SKILLS** | VPN peer connectivity from external nodes | Validates peer IPs, routing topology |
| **SAMBA_AGENT_SKILLS** | File sharing on infrastructure nodes | Coordinates with node IP assignments |
| **AUDIT_VALIDATION_AGENT_SKILLS** | Infrastructure topology consistency validation | Audits all agent IP references against authoritative topology |
| **SKILLS_MARKDOWN_GUIDELINE** | Standards for infrastructure documentation | Network Infrastructure Agent exemplifies topology documentation patterns |

---

## Skill Area 1: Infrastructure Topology Authority & Documentation

**Purpose:** Maintain and enforce the authoritative infrastructure topology documentation that all other agents reference.

**Capabilities:**
- Node inventory management (name, IP, role, services, status)
- Service-to-node mapping (which services run on which nodes)
- IP address allocation tracking (used, reserved, available)
- Infrastructure topology diagrams and documentation
- Redundancy and failover topology mapping
- Multi-site/region planning (future capability)
- Historical topology versions (IP scheme migration tracking)
- Topology change validation before deployment
- Consistency verification across all operational agents

**Examples:**

1. **Node Inventory Review:** Verify current infrastructure has 4 nodes (Gateway 24.204.72.65, SpaceBase 24.204.72.66, Hyperdrive 24.204.72.67, Laboratory 24.204.72.68), each with documented roles, services, and status

2. **Service Mapping Validation:** Confirm Docker Swarm distributed across Gateway (manager) and SpaceBase (worker), Prometheus runs on Gateway only, Samba containers on both Gateway and SpaceBase, WireGuard peers on external nodes

3. **IP Allocation Tracking:** Track that 4 IPs allocated (65-68), 7 reserved for expansion (69-75), 10 for service VIPs (76-85), 41 available for future (86-126)

4. **Redundancy Topology Documentation:** Verify Samba has redundant servers (Gateway + SpaceBase), Docker has redundant workers (though 1 manager single point of failure), WireGuard has redundant peers

5. **Topology Change Planning:** When adding new node, allocate from expansion pool (69-75), document service allocation, update all referencing agents

6. **Migration from Old Scheme:** When migrating from 24.204.72.64/26 to 24.204.72.64/26, track old→new IP mappings (24.204.72.65→24.204.72.65, 24.204.72.66→24.204.72.66, etc.)

7. **Multi-Region Planning:** Document future regional expansion (future: 24.204.72.128/26 for region 2, 24.204.72.192/26 for region 3), plan inter-region connectivity

8. **Scope Validation:** Ensure all infrastructure IPs documented in Network Infrastructure Agent, referenced (not replicated) in all other agents

**Constraints:**
- All infrastructure nodes must have documented roles (no orphaned/undocumented nodes)
- IP allocations must be unique (no duplicate addresses)
- All services must map to documented nodes (no services without infrastructure)
- Public IP scheme (24.204.72.64/26) means firewall/security implications (coordinate with Network Agent)
- /26 subnet limits future expansion (62 usable addresses total, careful planning required)
- Node IPs permanent within current scheme (changes require DNS/firewall updates across infrastructure)
- Redundancy topology must be current (if node goes down, failover procedures must be documented)
- IP address reservations must be respected (don't allocate from reserved pools without authorization)
- Multi-region planning requires careful coordination (routing, replication, failover)
- Historical versions must track all IP scheme migrations (audit trail for compliance)

---

## Skill Area 2: IP Address Scheme Management & Migration

**Purpose:** Plan, execute, and document IP address scheme changes while maintaining infrastructure consistency.

**Capabilities:**
- Current IP scheme documentation (24.204.72.64/26)
- Old IP scheme documentation (24.204.72.64/26 historical reference)
- IP-to-node mapping for all schemes
- Migration procedure planning (old→new transitions)
- DNS update coordination (if applicable)
- Firewall rule updates required for new scheme
- Agent documentation updates tracking
- Validation checklist for complete migrations
- Rollback procedures if migration fails
- IP scheme sizing for future needs

**Examples:**

1. **Current Scheme Documentation:** Document active 24.204.72.64/26 topology (4 nodes, 62 usable addresses, 58 available for expansion)

2. **Historical Scheme Reference:** Maintain record that system previously used 24.204.72.64/26 (4 nodes 24.204.72.65/3/4/5), useful for troubleshooting and audit trails

3. **Migration Planning for New Node:** When adding node, plan IP from reservation pool (24.204.72.69), document service allocation, schedule coordination with Docker/Network/Prometheus agents

4. **DNS Coordination:** If DNS names used, coordinate updates (gateway.internal → 24.204.72.65), validate all services use correct addresses post-migration

5. **Firewall Rule Updates:** When migrating to public IPs, identify which firewall rules change (if internal 24.204.72.64/26 had different rules than public 24.204.72.64/26)

6. **Agent Update Tracking:** When updating IPs across all agents, use Network Infrastructure Agent as source of truth, verify all agents updated consistently

7. **Validation Checklist Execution:** Verify all 6 operational agents updated with new IPs, spot-check examples in each agent, confirm no stale references

8. **Rollback Procedure:** If migration fails, have documented procedure to revert to previous IP scheme, restore DNS, update firewall rules

**Constraints:**
- IP migrations are high-risk operations (coordinate with multiple agents, test thoroughly)
- Public vs. private IP implications (24.204.72.64/26 is public, requires different security considerations)
- DNS dependencies (if DNS used, must update before or coordinate carefully during migration)
- Firewall rules tied to IP ranges (Network Agent must update rules for new scheme)
- All agents must update simultaneously (stale references create operational confusion)
- Rollback capability must be tested (don't migrate without knowing how to revert)
- External peer connectivity (Hyperdrive, Laboratory) may have hard-coded IPs in their configs
- No IP changes during active operations (schedule during maintenance window)
- Documentation must be updated before DNS/firewall go live (operators need current reference)
- Historical tracking prevents accidental IP reuse in future

---

## Skill Area 3: Service-to-Infrastructure Mapping & Coordination

**Purpose:** Document and maintain the mapping of services to infrastructure nodes, ensuring operational agents understand infrastructure dependencies.

**Capabilities:**
- Service inventory (Docker services, Prometheus, WireGuard, Samba, etc.)
- Service-to-node allocation (which services on which nodes)
- Service dependency documentation (Docker depends on network, Prometheus scrapes all nodes, etc.)
- Resource allocation per node (CPU/memory/storage reserved per service)
- Service failover/redundancy topology
- Backup/restore coordination across infrastructure
- Service scaling planning (adding replicas, new nodes)
- Performance baseline documentation (expected load per node)
- Service health monitoring topology (what monitors what)

**Examples:**

1. **Docker Service Mapping:** Document Swarm manager on Gateway (24.204.72.65), workers on SpaceBase (24.204.72.66), services distributed based on placement constraints

2. **Prometheus Monitoring Topology:** Prometheus runs on Gateway (24.204.72.65), scrapes node_exporter on all nodes (65, 66, 67, 68), Docker metrics from Swarm, Samba metrics from 65/66

3. **Samba Redundancy:** Samba container 1 on Gateway (24.204.72.65) serves primary media/backups/miscellanea, Samba container 2 on SpaceBase (24.204.72.66) for redundancy, both coordinate with Prometheus exporter

4. **WireGuard Peer Topology:** Hyperdrive (24.204.72.67) and Laboratory (24.204.72.68) are external peers, access jumpbox via 2222/tcp on Gateway, can reach SMB via SSH tunnel through jumpbox

5. **Resource Allocation:** Document Gateway gets 50% CPU (Swarm manager + Prometheus overhead), SpaceBase gets 40%, Hyperdrive/Laboratory get minimal (VPN only)

6. **Backup Topology:** Samba backup share on Gateway (24.204.72.65) receives TimeMachine backups from external peers via SSH tunnel, replicated to SpaceBase (24.204.72.66) for redundancy

7. **Scaling Planning:** If adding node 5 (24.204.72.69), plan service allocation (new Docker worker? New Samba secondary? New Prometheus target?), update all affected agent docs

8. **Service Health Monitoring:** Document which services monitor which (Prometheus monitors all, Docker health checks internal to containers, WireGuard monitors peer connectivity, Samba monitors connection limits)

**Constraints:**
- Service allocation affects performance (can't overload single node)
- Redundancy requires multiple nodes (single-node services are single point of failure)
- Resource limits must be respected (total CPU/memory across services can't exceed node capacity)
- Service dependencies must be documented (Docker needs Network, Prometheus needs all nodes accessible)
- Failover procedures must be tested (if node fails, services must migrate/recover automatically)
- Scaling must be coordinated across agents (adding node requires Docker/Network/Prometheus updates)
- Backup topology must account for storage capacity (1TB Samba backup, growth planning)
- Monitoring topology must not create bottlenecks (Prometheus on single node, if overwhelmed creates blind spots)
- External peer access requires jumpbox security (no direct SMB access outside network, must tunnel)

---

## Skill Area 4: Infrastructure Consistency Validation & Audit

**Purpose:** Audit all infrastructure-related documentation across operational agents to ensure consistency with authoritative topology.

**Capabilities:**
- Node IP reference consistency checking (all agents use 24.204.72.65-68 consistently)
- Service-to-node mapping verification (no agents document contradictory service locations)
- Port allocation consistency (Docker ports, Prometheus ports, SMB ports same everywhere)
- Redundancy documentation consistency (Samba redundancy documented in Samba + Docker + Network agents)
- Failover topology validation (all agents understand failover procedures)
- Agent reference to authoritative topology (all agents link to Network Infrastructure Agent)
- Infrastructure scaling readiness validation (expansion IPs reserved, documented)
- Cross-agent dependency validation (Docker needs Network Agent documented everywhere)
- Infrastructure change impact analysis (adding node affects which agents, in what ways)

**Examples:**

1. **Node IP Consistency Audit:** Verify all agents reference Gateway as 24.204.72.65 (not 24.204.72.65, not 24.204.72.1), SpaceBase as 24.204.72.66, Hyperdrive/Laboratory as 67/68

2. **Service Location Verification:** Confirm all agents document Prometheus on Gateway (24.204.72.65) only, not replicated to SpaceBase, not running on peers

3. **Port Consistency Check:** Verify Docker Swarm ports (2377, 7946, 4789) documented same way in Docker Agent and Network Agent, no conflicting allocations

4. **Redundancy Documentation Audit:** Confirm Samba redundancy (containers on 65 and 66) documented in Samba Agent AND referenced in Docker Agent (service placement), and firewall rules in Network Agent allow both

5. **Failover Topology Validation:** Verify all agents understand "if Gateway (24.204.72.65) fails, Swarm manager gone but workers continue on SpaceBase (24.204.72.66)"

6. **Reference to Authoritative Source:** Audit that all operational agents have "Reference Implementation" or similar section linking to Network Infrastructure Agent for node IPs, not embedded IPs

7. **Scaling Impact Analysis:** When planning node 5 (24.204.72.69), identify which agents need updates (Docker for new worker, Network for firewall rules, Prometheus for new scrape target, Audit for validation)

8. **Dependency Chain Validation:** Verify infrastructure understanding in all agents (e.g., "Samba depends on Docker (containers) depends on Network (firewall) depends on Network Infrastructure (node IPs)")

**Constraints:**
- Consistency validation is point-in-time (agents may drift if changes not coordinated)
- Can't validate infrastructure reality (only documents, not actual connectivity)
- Circular dependencies possible (if Network Infra Agent references Audit Agent who audits Network Infra)
- False positives in validation (may flag redundancy as "contradiction" if phrased differently)
- Scaling impact analysis is inferential (can't predict all downstream effects)
- Historical changes not captured in current docs (would need version control integration)

---

## Skill Area 5: Future Infrastructure Planning & Scaling

**Purpose:** Plan and coordinate infrastructure expansion while maintaining consistency and avoiding address conflicts.

**Capabilities:**
- Capacity planning (62 total usable addresses, current usage, future needs)
- Expansion node planning (nodes 5-11 from pool 24.204.72.69-75)
- Service VIP allocation (10 addresses reserved 76-85 for load balancers if needed)
- Multi-region topology planning (future: region 2 at 24.204.72.128/26, region 3 at 24.204.72.192/26)
- Inter-region connectivity planning (routing between regions, replication)
- Failover region planning (if primary region fails, fail to secondary)
- Future IP scheme planning (if /26 insufficient, migrate to /25 or larger)
- Scaling testing procedures (test new node addition in non-prod first)
- Growth forecasting (estimate when expansion needed)

**Examples:**

1. **Capacity Planning:** Document that 24.204.72.64/26 supports 62 addresses, currently using 4 (Gateway, SpaceBase, Hyperdrive, Laboratory), 58 available

2. **Expansion Node Planning:** Allocate 24.204.72.69 for future node 5, 24.204.72.70 for node 6, etc., through 24.204.72.75 (7 total expansion nodes available)

3. **Service VIP Allocation:** Reserve 24.204.72.76-85 for future load balancers (if Docker Swarm needs external load balancer) or service VIPs

4. **Multi-Region Topology:** Plan region 2 in 24.204.72.128/26, region 3 in 24.204.72.192/26, same /26 structure in each, enables consistent agent documentation patterns

5. **Inter-Region Routing:** Document future VPN/routing between regions (WireGuard tunnels? BGP? DNS round-robin?), plan failover scenarios

6. **Failover Region Planning:** If region 1 (24.204.72.65-68) fails, can fail over to region 2 (24.204.72.129-132), coordinate DNS changes

7. **Scaling Test Procedure:** Add node 5 to test environment first, validate all agents work, confirm failover procedures, then promote to production

8. **Growth Forecasting:** Track infrastructure metrics (CPU, memory, storage, connections), estimate when expansion needed (e.g., "if usage grows 10% annually, need new region in 3 years")

**Constraints:**
- /26 subnet is finite (62 addresses, can't expand indefinitely without new scheme)
- Multi-region adds complexity (routing, replication, failover more complex)
- Future planning is speculative (actual needs may differ from forecast)
- New regions require new subnets (can't split 24.204.72.64/26 further)
- Scaling must be coordinated (can't add node without updating all affected agents)
- Testing must be thorough (undiscovered issues in new node break operational consistency)

---

## Skill Area 6: DNS & Service Discovery Integration

**Purpose:** Plan and coordinate DNS naming and service discovery patterns for infrastructure nodes and services.

**Capabilities:**
- DNS naming conventions (gateway.local, spacebase.local, hyperdrive.external, laboratory.external)
- Service discovery mechanisms (if using Consul, etc.)
- DNS failover planning (if primary node fails, secondary addresses)
- Service record documentation (SRV records for services if applicable)
- External name resolution (if peers access via DNS names vs. IPs)
- Internal vs. external naming (different names for internal vs. external access)
- DNS update procedures (when IPs change, how to update DNS)
- Name resolution validation (verify all services reachable via documented names)
- Dynamic DNS coordination (if applicable)

**Examples:**

1. **DNS Naming Scheme:** Document gateway.local → 24.204.72.65, spacebase.local → 24.204.72.66, hyperdrive.external → 24.204.72.67, laboratory.external → 24.204.72.68

2. **Service Discovery:** If using Consul, document services registry (Docker swarm, Prometheus, Samba, WireGuard) automatically registered, external peers query via service names

3. **DNS Failover:** If gateway.local fails, DNS can redirect to spacebase.local for critical services (e.g., Samba failover)

4. **Service Records:** Document SRV records if applicable (e.g., _smb._tcp.local → Samba on 24.204.72.65 and 24.204.72.66)

5. **External Access:** External peers (Hyperdrive, Laboratory) access via hyperdrive.external, laboratory.external (if DNS available externally)

6. **Internal vs. External Names:** gateway.local (internal only), gateway.external (if publicly accessible)

7. **DNS Update Procedure:** When migrating from 24.204.72.64/26 to 24.204.72.64/26, update DNS records (gateway.local 24.204.72.65 → 24.204.72.65), coordinate timing with agent updates

8. **Name Resolution Validation:** After DNS updates, verify all services reachable via names (smbclient -L gateway.local, curl http://gateway.local:9090, etc.)

**Constraints:**
- DNS complexity adds layer of indirection (more moving parts if things fail)
- External DNS may not resolve internal IPs (need split-horizon DNS if both internal and external)
- DNS changes can take time to propagate (TTL delays, cache invalidation)
- Service discovery adds operational overhead (must keep registry in sync)
- Name changes less flexible than IP changes (more systems may depend on names than IPs)
- External peer access to internal DNS requires careful security (don't expose internal DNS to external)

---

## Skill Area 7: Infrastructure Monitoring & Health Verification

**Purpose:** Document infrastructure health monitoring, alerting, and remediation procedures.

**Capabilities:**
- Node connectivity monitoring (ping all nodes, verify reachability)
- Node resource monitoring (CPU, memory, disk, network utilization per node)
- Service availability monitoring (each service running on expected node)
- Infrastructure redundancy validation (verify failover paths work)
- Alert routing (which alerts for which infrastructure components)
- Infrastructure incident response (if node fails, what to do)
- Infrastructure recovery procedures (restore node, rejoin cluster)
- Capacity monitoring (track usage growth, plan expansion)
- Infrastructure change validation (after changes, verify still healthy)

**Examples:**

1. **Node Connectivity Check:** Prometheus node_exporter on all 4 nodes (65, 66, 67, 68) reports connectivity, alerts if any node unreachable

2. **Resource Monitoring:** Track CPU/memory/disk on Gateway (should be highest usage), SpaceBase (should be medium), Hyperdrive/Laboratory (should be minimal)

3. **Service Availability:** Prometheus scrape targets for Docker (Swarm metrics), Prometheus (itself), Samba (exporter), WireGuard (exporter), all should be up

4. **Redundancy Validation:** Periodically simulate Gateway failure, verify Swarm continues on SpaceBase, Prometheus continues (or fails gracefully), Samba on 66 continues

5. **Alert Routing:** Alerts for Gateway failures to critical channel (single point of failure), SpaceBase failures to normal channel (less critical), Hyperdrive/Laboratory failures to low channel (external only)

6. **Incident Response:** If Gateway (24.204.72.65) fails, runbook: check Swarm manager status, fail over to SpaceBase if needed, check Prometheus, check Samba

7. **Recovery Procedure:** If node fails, power-cycle, rejoin cluster, update Audit Agent if needed, restart services, validate health

8. **Capacity Monitoring:** Track that Gateway CPU usage stayed under 70%, memory under 80%, disk under 85%, forecast when expansion needed

**Constraints:**
- Monitoring creates additional infrastructure load (Prometheus collector itself needs resources)
- Alerts can be noisy (too many false positives reduce operator responsiveness)
- Monitoring lag (real failures may occur faster than monitoring detection)
- Incident response is manual (runbooks help but human decision still needed)
- Recovery procedures must be tested (untested procedures often fail when needed)

---

## Diagnostic Workflow 1: Node Onboarding & Validation

**Problem:** New node being added to infrastructure, need to ensure it integrates correctly and all agents document it properly.

**Steps:**
1. Identify new node requirement (e.g., "need additional Docker worker for capacity")
2. Allocate IP from expansion pool (24.204.72.69 is next available)
3. Document node name (e.g., "Expansion1"), role (e.g., "Docker worker"), services to run
4. Update Network Infrastructure Agent: add new node to node inventory table, update IP allocation tracking, document service allocation
5. Identify which operational agents must update (if Docker worker: Docker Agent needs Swarm join procedure, Network Agent needs firewall rules, Prometheus Agent needs node_exporter scrape target)
6. Create change list for each affected agent (before/after examples for each agent)
7. Pre-stage changes (prepare updated agent files, don't deploy yet)
8. Test in non-prod environment if possible (add test node, verify all agents work correctly)
9. Run Audit Agent pre-deployment validation on all 6 affected agent files (structural completeness, cross-reference validation, technical consistency)
10. Deploy changes to all affected agents simultaneously (minimize inconsistency window)
11. Verify new node joins Swarm cluster, appears in Prometheus scrape targets, firewall rules allow connectivity
12. Re-run Audit Agent to validate post-deployment consistency
13. Document completion in Network Infrastructure Agent (add operational node to inventory, move from "planned" to "active")

**Expected Outcomes:**
- New node integrated consistently across all agents
- No documentation gaps or inconsistencies
- All services on new node properly monitored and coordinated
- Failover procedures account for new node
- Infrastructure remains healthy and coordinated

**Prerequisites:**
- Infrastructure capacity available (IP pool has available addresses, physical/virtual resources exist)
- Node hardware/virtualization prepared and ready
- Operator understands infrastructure dependencies (Docker→Network→Infrastructure→Audit coordination)
- Audit Agent available to validate consistency
- Change control process followed (if applicable)

---

## Diagnostic Workflow 2: Infrastructure IP Scheme Migration

**Problem:** Need to migrate from current IP scheme (or to new scheme if current one becomes invalid) while maintaining infrastructure consistency.

**Steps:**
1. Document current IP scheme (24.204.72.64/26 currently active)
2. Validate new IP scheme: verify range is large enough, public vs. private implications, firewall implications
3. Create node mapping (old IP → new IP, e.g., 24.204.72.65 → 24.204.72.65)
4. Identify affected agents (all 6 operational agents reference IPs)
5. Create migration checklist: which agent sections must change, what examples need updating, which constraints/documentation affected
6. Coordinate with DNS (if DNS names used, plan DNS updates, coordinate timing)
7. Coordinate with Network Agent (firewall rules may differ for new scheme)
8. Prepare all agent updates (don't deploy yet): generate before/after for every IP reference
9. Pre-stage backup of current agent documentation (in case rollback needed)
10. Schedule maintenance window (migrations are high-risk, do during low-traffic period)
11. Execute DNS updates first (if applicable), validate propagation
12. Execute agent updates (deploy updated files to all agents simultaneously)
13. Execute firewall rule updates (Network Agent coordinates)
14. Test infrastructure: verify all nodes reachable on new IPs, services running, redundancy intact
15. Run Audit Agent validation (comprehensive audit of all agents for consistency with new scheme)
16. If validation passes: migration complete, document in Network Infrastructure Agent
17. If validation fails: execute rollback (restore DNS, restore agents, restore firewall rules)

**Expected Outcomes:**
- All infrastructure nodes operating on new IP scheme
- All agents consistently documenting new IPs
- No stale IP references in any agent
- Services continue operating during migration
- Failover/redundancy intact on new scheme
- Documented rollback if needed

**Prerequisites:**
- Complete IP scheme planned and validated
- All affected agents identified
- Maintenance window scheduled
- Rollback procedures documented and tested
- Audit Agent available for validation
- DNS coordination planned (if applicable)
- Network team ready to update firewall rules

---

## Diagnostic Workflow 3: Infrastructure Consistency Audit

**Problem:** Periodic audit needed to ensure all agents remain consistent with authoritative Network Infrastructure Agent topology.

**Steps:**
1. Receive audit request (monthly/quarterly schedule, or triggered by infrastructure change)
2. Load current Network Infrastructure Agent (authoritative topology: node IPs 65-68, services, allocation)
3. For each operational agent (Docker, Network, Prometheus, WireGuard, Samba):
   a. Scan for IP references (24.204.72.65, 24.204.72.66, 24.204.72.67, 24.204.72.68)
   b. For each IP found, verify it matches Network Infrastructure Agent (correct node, correct role documented)
   c. Verify service-to-node mapping matches Network Infrastructure Agent
   d. Check for stale references (IPs documented that don't exist in current topology)
   e. Verify redundancy documentation matches Network Infrastructure Agent
4. Cross-agent consistency checks:
   a. If Docker Agent mentions Samba on 24.204.72.66, verify Samba Agent documents itself on 24.204.72.66
   b. If Network Agent documents firewall rules for 24.204.72.67, verify WireGuard Agent documents this peer at this IP
5. Compile findings:
   a. Consistency issues found (e.g., agent A says 24.204.72.65 is Gateway, agent B says it's SpaceBase)
   b. Stale references found (e.g., agent still mentions 24.204.72.65 Gateway)
   c. Missing references found (e.g., new node 24.204.72.69 not documented in Docker Agent)
6. Severity classify issues (critical: contradictions, major: stale references, minor: documentation quality)
7. Generate audit report with specific remediation (file, line numbers, before/after text for each issue)
8. Track remediation (prioritize critical, schedule fixes, verify deployment)
9. Re-audit after fixes to confirm consistency restored
10. Document audit completion (when done, issues found/fixed, current consistency score)

**Expected Outcomes:**
- All agents consistent with Network Infrastructure Agent topology
- No contradictions or stale references
- Infrastructure remains coordinated
- Drift detected early before causing operational issues
- Documented audit trail

**Prerequisites:**
- Network Infrastructure Agent current and accurate
- All 6 operational agents available for review
- Audit tool/procedure available
- Remediation process defined

---

## Validation Checklist

**Infrastructure Topology Baseline:**
- [ ] Network range documented (24.204.72.64/26, 62 usable addresses)
- [ ] All 4 nodes documented with IPs (Gateway 65, SpaceBase 66, Hyperdrive 67, Laboratory 68)
- [ ] Node roles documented (manager, worker, peer, peer)
- [ ] Services per node documented (Docker, Prometheus, Samba, WireGuard as applicable)
- [ ] IP allocation tracking current (4 used, 7 reserved for expansion, 10 for VIPs, 41 available)
- [ ] Port allocations documented (Docker 2222/5000-5999/8000-9999, Prometheus 9090/9093/9100, WireGuard 51820, SMB 445/137-138)
- [ ] Redundancy topology documented (which services have backups on which nodes)
- [ ] Failover procedures documented (what happens if each node fails)

**Agent Reference Validation:**
- [ ] All 6 operational agents reference Network Infrastructure Agent for authoritative topology
- [ ] No agents have hard-coded IPs (all reference Network Infrastructure Agent)
- [ ] Docker Agent documents services by node (node 65: Swarm manager + Prometheus, node 66: Swarm worker + Samba, etc.)
- [ ] Network Agent documents firewall rules by IP range (24.204.72.65-68 allowed, others blocked/NATed as appropriate)
- [ ] Prometheus Agent documents scrape targets by node IP (65, 66, 67, 68 all targeted)
- [ ] WireGuard Agent documents peer IPs (67 and 68) consistent with Network Infrastructure Agent
- [ ] Samba Agent documents server IPs (65 and 66) consistent with Network Infrastructure Agent
- [ ] Audit Agent can validate all above in automated audit workflow

**IP Scheme Migration Preparation:**
- [ ] Old IP scheme documented (24.204.72.64/26 with node mapping 1→65, 3→66, 4→67, 5→68)
- [ ] New IP scheme documented (24.204.72.64/26 current)
- [ ] Migration procedure documented (DNS, firewall, agent updates, testing, rollback)
- [ ] Pre-migration checklist complete (all prerequisites met)
- [ ] Post-migration validation procedure documented (which tests to run, expected results)

**Future Expansion Planning:**
- [ ] Expansion node IP pool documented (24.204.72.69-75 reserved)
- [ ] Service VIP pool documented (24.204.72.76-85 reserved)
- [ ] Future region planning (24.204.72.128/26 for region 2, 24.204.72.192/26 for region 3, planned not active)
- [ ] Scaling triggers documented (when to add expansion node, how many new nodes per trigger)
- [ ] Resource allocation per node documented (expected CPU/memory/disk per service)

**Consistency Audit Results:**
- [ ] All agents consistent with Network Infrastructure Agent topology
- [ ] No IP contradictions found (same IP documented with same node name in all agents)
- [ ] No stale references (all IPs in agents are current, none refer to old scheme)
- [ ] All redundancy documented consistently (if Samba on 65+66, documented in Docker, Network, Samba, Prometheus)
- [ ] All failover procedures documented and understood by all agents
- [ ] Audit score ≥95% (minor issues only, no critical contradictions)

---

## Best Practices

1. **Single Source of Truth:** All infrastructure IPs documented in Network Infrastructure Agent ONLY. All other agents REFERENCE (not duplicate) this topology. Prevents inconsistency when changes made.

2. **Node Naming Convention:** Use descriptive names (Gateway, SpaceBase, Hyperdrive, Laboratory), include role (Swarm manager, worker, peer), allows easy understanding of infrastructure topology.

3. **IP Allocation Discipline:** Allocate from pools with purpose (current 65-68, expansion 69-75, VIP 76-85). Don't skip numbers, prevents confusion and accidental conflicts.

4. **Redundancy Documentation:** When service has redundant deployment (Samba on 65+66), document in all affected agents (Samba Agent, Docker Agent for containers, Network Agent for firewall rules).

5. **Failover Planning:** For each node, document what happens if it fails (if Gateway fails: Swarm continues on SpaceBase, Prometheus + Samba potentially down). Test procedures.

6. **DNS Coordination:** If using DNS names, document naming scheme and update procedures. Understand how DNS affects failover (DNS cache TTL delays).

7. **Change Control:** Infrastructure changes (adding node, IP migration) coordinated through Network Infrastructure Agent, validated by Audit Agent before deployment to all agents.

8. **Audit Frequency:** Run consistency audit monthly (lightweight), quarterly (comprehensive). Catch drift early before it compounds.

9. **Capacity Planning:** Track node utilization, forecast growth, plan expansion before infrastructure saturated. Document capacity limits (62 addresses in current /26).

10. **Documentation Maintenance:** Keep Network Infrastructure Agent current (add/remove nodes promptly, update IP allocations, track historical schemes). Stale docs cause operational confusion.

11. **Testing Before Deployment:** Test all infrastructure changes (new node, IP migration, failover) in non-prod first. Unexpected issues in prod are dangerous.

12. **Clear Naming Across Scope:** Use consistent naming for nodes across all agents (not "node1" in one agent, "server_A" in another). Makes it easy to correlate docs.

---

## Reference Implementation

### Coordinated with Docker Agent
The Network Infrastructure Agent provides authoritative node topology that Docker Agent references:
- **Node allocation:** Gateway (24.204.72.65) runs Swarm manager, SpaceBase (24.204.72.66) runs worker
- **Redundancy:** Docker service placement constraints reference node IPs from Network Infrastructure Agent
- **Expansion coordination:** Adding new Docker worker requires IP allocation from Network Infrastructure Agent, firewall rules from Network Agent, service configuration in Docker Agent
- **Example:** When adding expansion node (24.204.72.69), Network Infrastructure Agent allocates IP, Docker Agent documents service placement, Audit Agent validates consistency

### Coordinated with Network Agent
The Network Infrastructure Agent defines IP ranges that Network Agent secures with firewall:
- **Firewall authority:** Network Agent maintains port rules, Network Infrastructure Agent maintains IP/node rules
- **Port allocation:** Network Infrastructure Agent coordinates with Network Agent to ensure no port conflicts
- **Node firewall rules:** Network Infrastructure Agent documents which nodes need which firewall access
- **Example:** Network Infrastructure Agent documents 4 nodes (65-68), Network Agent documents firewall rules allowing Docker ports on 65/66, Prometheus ports on 65, WireGuard port on 67/68

### Coordinated with Prometheus Agent
The Network Infrastructure Agent documents all monitoring targets that Prometheus Agent scrapes:
- **Scrape targets:** Prometheus targets all node IPs (65, 66, 67, 68) for node_exporter
- **Service metrics:** Network Infrastructure Agent documents services on each node, Prometheus Agent documents which services it monitors
- **Expansion:** Adding new node (24.204.72.69) requires Prometheus Agent to add scrape target for new node_exporter
- **Example:** Network Infrastructure Agent adds node 69 to topology, Prometheus Agent adds target 24.204.72.69:9100 to scrape config

### Coordinated with WireGuard Agent
The Network Infrastructure Agent documents external peer IPs that WireGuard Agent manages:
- **Peer IPs:** WireGuard peers at 24.204.72.67 (Hyperdrive) and 24.204.72.68 (Laboratory) documented by Network Infrastructure Agent
- **Failover:** If peer IP changes, Network Infrastructure Agent updated, WireGuard Agent updates configuration
- **Jumpbox coordination:** WireGuard peers access internal services via jumpbox on Gateway (24.204.72.65)
- **Example:** Network Infrastructure Agent documents Hyperdrive peer at 67, WireGuard Agent documents routing and key management for that peer

### Coordinated with Samba Agent
The Network Infrastructure Agent documents Samba server IPs that Samba Agent operates:
- **Server IPs:** Samba servers on 24.204.72.65 (primary) and 24.204.72.66 (secondary) documented by Network Infrastructure Agent
- **Redundancy:** Network Infrastructure Agent documents both server IPs, Samba Agent documents service redundancy across both
- **Monitoring:** Network Infrastructure Agent documents Samba exporter runs on both servers, Prometheus Agent scrapes both
- **Example:** Network Infrastructure Agent maps Samba to nodes 65+66, Samba Agent documents container deployment on both nodes

### Coordinated with Audit & Validation Agent
The Audit & Validation Agent validates all agents remain consistent with Network Infrastructure Agent topology:
- **Topology authority:** Network Infrastructure Agent is source of truth, Audit Agent verifies all agents reference it correctly
- **Consistency checking:** Audit Agent scans all 6 operational agents for IP references, validates they match Network Infrastructure Agent
- **Migration validation:** When IP scheme changes, Audit Agent validates all agents updated consistently
- **Quarterly audit:** Audit Agent runs comprehensive consistency audit, flags stale references or contradictions
- **Example:** Audit Agent finds Docker Agent mentions "24.204.72.65 Gateway" but Network Infrastructure Agent says "24.204.72.65 Gateway", flags as stale reference, generates remediation

### Coordinated with SKILLS_MARKDOWN_GUIDELINE
The Network Infrastructure Agent exemplifies infrastructure topology documentation patterns:
- **Structure:** Uses SKILLS_MARKDOWN_GUIDELINE format for infrastructure documentation
- **Patterns:** Multi-agent coordination examples for infrastructure changes
- **Examples:** Node onboarding, IP migration workflows show guideline patterns in practice
- **Reference:** SKILLS_MARKDOWN_GUIDELINE references Network Infrastructure Agent as example of topology documentation

---

## Known Limitations & Gotchas

1. **IP Scheme Rigidity:** /26 subnet fixed at 62 addresses, can't expand further without new scheme. Plan carefully for growth.

2. **Public vs. Private:** 24.204.72.64/26 is public IP space, very different security implications from private 24.204.72.64/26. Coordinate with Network Agent on firewall implications.

3. **DNS Complexity:** If DNS used, adds layer of indirection. DNS propagation delays (TTL), split-horizon issues (internal vs. external DNS) complicate migrations.

4. **Failover Complexity:** Single Swarm manager (Gateway 24.204.72.65) is single point of failure. If Gateway fails, Swarm continues but no new services can be created. Document this limitation.

5. **External Peer Rigidity:** Hyperdrive and Laboratory peers may have IPs hard-coded in their configs. IP changes require external coordination.

6. **Monitoring Creates Load:** Prometheus on Gateway (24.204.72.65) monitoring all nodes adds network and CPU load. If Gateway overloaded, monitoring degrades.

7. **Replication Not Documented:** Samba appears on 65+66, but is it active-active (both servers independent) or active-passive (65 primary, 66 standby)? Document clearly.

8. **Service VIPs Not Yet Used:** Addresses 76-85 reserved for VIPs but not currently allocated. If future load balancer added, coordinate IP allocation.

9. **Multi-Region Unplanned:** Region 2 (128/26) and Region 3 (192/26) planned but not active. If actually deployed, significant replication/failover complexity.

10. **Historical Scheme Hidden:** Old 24.204.72.64/26 scheme only documented in Network Infrastructure Agent. If operator only reads other agents, won't see history of previous scheme.

---

**Last Updated:** September 16, 2026  
**Version:** 1.0 - Initial Release  
**Network:** 24.204.72.64/26 (Public IP Address Space)  
**Nodes:** 4 active (Gateway, SpaceBase, Hyperdrive, Laboratory)  
**Capacity:** 62 total addresses, 4 used, 58 reserved/available  
**Status:** PRODUCTION READY

