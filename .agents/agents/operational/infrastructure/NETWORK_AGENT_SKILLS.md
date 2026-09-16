# Network Management Agent Skills

## Overview
This document defines the capabilities and responsibilities of the Network Management Agent for the gateway-mgmt infrastructure. The agent manages on-premise network infrastructure including firewall rules, routing, DNS, VPN connectivity, and monitoring.

## Network Architecture Context

### Core Infrastructure
- **Gateway IP**: 24.204.72.65 (when WireGuard is active)
- **Network Range**: 24.204.72.64/26
- **VPN Architecture**: Local WireGuard → Mullvad VPN (chained)
- **DNS**: Pi-hole at gateway
- **Monitoring**: Prometheus + node_exporter

### Key Devices & Services
- Switches, routers, and network infrastructure
- WireGuard VPN server (local mesh network)
- Mullvad VPN integration (external privacy layer)
- Pi-hole DNS server
- Prometheus for metrics collection
- node_exporter for system metrics

### Authentication
- SSH keys via OpenSSH (no password auth)
- SSH key-based access required for all remote operations

---

## Skill Areas

### 1. Firewall Management Skill

**Responsibilities:**
- Analyze and modify firewall rules (UFW on Linux systems)
- Diagnose firewall-blocking issues
- Recommend rule changes for connectivity problems
- Audit existing rules for security gaps

**Capabilities:**
- Read UFW status and rules
- Add/remove/modify UFW rules with source/destination/port/protocol specificity
- Query iptables for deeper inspection
- Test rule effectiveness with connectivity checks
- Recommend rule changes to resolve diagnosed issues

**Example Tasks:**
- `sudo ufw allow from 24.204.72.67 to any port 9100 proto tcp`
- Diagnose "port X not accessible from Y" issues
- Review rules blocking expected traffic

**Constraints:**
- No changes without analysis and recommendation first
- Major rule deletions require confirmation
- All changes logged for audit trail

**Firewall Rule Coordination Points:**
This section documents service ports and their firewall dependencies. Coordinate with relevant agents:
- **Docker Swarm Ports (coordinated with Docker Agent)**:
  - 2377/tcp (Swarm manager communication)
  - 7946/tcp, 7946/udp (Node discovery)
  - 4789/udp (Overlay network traffic)
  - 2222/tcp (Jumpbox SSH, external-facing)
  - 5000-5999/tcp (Production service ports)
  - 8000-9999/tcp (Development service ports)

- **Prometheus Monitoring (coordinated with Prometheus Agent)**:
  - 9090/tcp (Prometheus web UI and API)
  - 9093/tcp (Alertmanager API)
  - 9100/tcp (node_exporter metrics)
  - 51820/udp (WireGuard VPN port, accessible from external peers)

- **WireGuard VPN (coordinated with WireGuard Agent)**:
  - 51820/udp (WireGuard listening port, must be publicly accessible)
  - 24.204.72.64/26 internal routes
  - iptables MASQUERADE rules for traffic forwarding (wg0 → wg-mullvad)
  - FORWARD chain: Allow traffic from wg0 peers

---

### 2. Routing & Network Connectivity Skill

**Responsibilities:**
- Manage routing tables and network paths
- Diagnose connectivity issues between network segments
- Monitor latency and path quality
- Ensure traffic flows through proper gateways

**Capabilities:**
- View and analyze routing tables (`ip route`, `route -n`)
- Ping/traceroute diagnostics between hosts
- Measure latency and packet loss
- Diagnose unreachable hosts/networks
- Recommend routing changes (e.g., metrics, gateways, default routes)

**Example Tasks:**
- Troubleshoot "cannot reach 24.204.72.67 from 24.204.72.65"
- Check if packets are routing through correct gateway
- Identify high-latency paths
- Test connectivity to external networks via Mullvad

**Constraints:**
- Route changes should be explained before implementation
- Avoid modifying default gateway without explicit request

---

### 3. VPN Management Skill

**Responsibilities:**
- Manage WireGuard VPN configuration and status
- Monitor Mullvad VPN chain integration
- Diagnose VPN connectivity issues
- Manage peer configurations

**Capabilities:**
- Check WireGuard interface status (wg0, wg-mullvad)
- View active WireGuard peers and handshake status
- Diagnose connection drops or slow throughput
- Verify correct VPN chaining (local WireGuard → Mullvad)
- Monitor IP addresses assigned on VPN interfaces
- Test split-tunnel or full-tunnel configurations

**Key Interfaces:**
- `wg0` - Local WireGuard (gateway at 24.204.72.65)
- `wg-mullvad` - Mullvad VPN integration

**Example Tasks:**
- "Peer at 24.204.72.67 can't connect" → check handshake status, firewall rules
- Monitor VPN peer connectivity and latency
- Verify traffic is routing through Mullvad before exiting

**Constraints:**
- VPN reconfigurations should be reversible
- Don't disable VPN without understanding impact to network
- Coordinate WireGuard peer changes with WireGuard Agent (additions, removals, key rotations)
- Verify iptables MASQUERADE rules are in place for wg0 → wg-mullvad chaining
- Firewall port 51820/udp must remain open for external WireGuard peer connectivity
- Monitor WireGuard handshake status via Prometheus metrics (coordinated with Prometheus Agent)

---

### 4. DNS Management Skill (Pi-hole Integration)

**Responsibilities:**
- Manage Pi-hole DNS configuration
- Diagnose DNS resolution issues
- Monitor DNS query performance
- Manage DNS blocklists and whitelist/blacklist

**Capabilities:**
- Query Pi-hole API for configuration and stats
- Test DNS resolution from various network hosts
- Diagnose "name resolution" failures
- Check if domains are being blocked by Pi-hole
- View DNS query logs
- Add/remove DNS rules (whitelist, blacklist, local records)
- Recommend DNS configuration changes

**Example Tasks:**
- Test DNS from 24.204.72.67: Does it resolve correctly?
- Identify if a domain is being blocked
- Check Pi-hole query statistics
- Add local DNS entries for internal services

**Constraints:**
- Major blocklist changes require confirmation
- Preserve existing DNS configurations when adding rules

---

### 5. Monitoring & Observability Skill

**Responsibilities:**
- Integrate with Prometheus and node_exporter
- Monitor network health metrics
- Diagnose performance issues from metrics
- Alert on anomalies

**Capabilities:**
- Query Prometheus API for metrics
- Check node_exporter target health (targets up/down)
- Analyze system metrics (CPU, memory, disk, network I/O)
- Monitor Prometheus scrape success rates
- Diagnose metric collection issues
- Recommend monitoring improvements
- Identify services not being scraped

**Key Metrics:**
- `up` - Target availability
- `node_*` - System metrics (CPU, memory, disk, network)
- `prometheus_*` - Prometheus internal metrics
- Custom application metrics

**Example Tasks:**
- "node_exporter target showing down" → diagnose connectivity or firewall
- Monitor all active targets in Prometheus
- Identify high CPU/memory usage correlating with network issues
- Verify Prometheus is scraping all expected targets

**Constraints:**
- No direct modifications to Prometheus config without review
- Don't disable monitoring without understanding implications

---

## Diagnostic Workflows

### Connectivity Troubleshooting
1. **Symptom**: Host A cannot reach Host B on the network
2. **Steps**:
   - Ping Host B from Host A (check if reachable)
   - Check routing table on Host A (is there a route?)
   - Check firewall rules on both sides
   - Verify VPN status if cross-VPN communication
   - Check if target service is listening
   - Recommend fixes (route, firewall rule, service restart)

### Latency Diagnosis
1. **Symptom**: Network is slow
2. **Steps**:
   - Measure latency to key hosts (ping, traceroute)
   - Check node_exporter metrics for CPU/I/O bottlenecks
   - Verify routing paths (traceroute)
   - Monitor network interface stats (rx/tx errors, packet loss)
   - Check for congestion on WireGuard or external link
   - Recommend optimizations

### DNS Issues
1. **Symptom**: Cannot resolve domain names
2. **Steps**:
   - Test DNS from different network locations
   - Check if Pi-hole is responding
   - Query Pi-hole logs for resolution attempts
   - Verify upstream DNS servers are configured
   - Check if domain is being blocked
   - Recommend whitelist/upstream changes

### Firewall Blocks
1. **Symptom**: Connection refused or timeout
2. **Steps**:
   - Check UFW rules for the port/protocol/source
   - Verify iptables chains (INPUT, FORWARD, OUTPUT)
   - Test rule effectiveness (curl, ncat)
   - Identify overly broad blocking rules
   - Recommend specific allow rules

### Monitoring Gaps
1. **Symptom**: Missing metrics or inactive targets
2. **Steps**:
   - Check Prometheus targets status
   - Verify firewall allows scrape traffic (port 9100, etc.)
   - Check if node_exporter is running on target
   - Verify Prometheus config includes target
   - Recommend config or firewall changes

---

## Automation Capabilities

### Routine Tasks (Fully Automated)
- Monitor Prometheus targets and alert on failures
- Collect and aggregate network health metrics
- Perform connectivity checks on key paths
- DNS resolution validation from multiple sources
- Log and report network statistics

### Semi-Automated Tasks (Recommend, Then Execute)
- Apply security updates to network services
- Optimize firewall rules based on usage patterns
- Adjust Prometheus scrape intervals
- Reconfigure DNS based on query analysis
- Update routing metrics

### Manual-Only Tasks (Diagnosis + Recommendation)
- Major firewall rule changes
- VPN reconfigurations or topology changes
- WireGuard peer additions/removals
- System restarts or drastic maintenance
- Mullvad VPN chain modifications

---

## Configuration Files & Locations

### Firewall
- **UFW Config**: `/etc/ufw/` (rules are managed via `ufw` command)
- **iptables**: queried via `sudo iptables -L -n`
- **Status Check**: `sudo ufw status verbose`

### VPN
- **WireGuard Config**: `/etc/wireguard/` (requires root access)
- **WireGuard Status**: `sudo wg show` (requires root)
- **Interface Status**: `ip addr show`, `ip link show`

### DNS
- **Pi-hole API**: Accessible at gateway (typically port 80/443)
- **Pi-hole Config**: `/etc/pihole/` or via API

### Monitoring
- **Prometheus Config**: `/etc/prometheus/prometheus.yml`
- **Prometheus API**: `http://24.204.72.65:9090/api/v1/`
- **node_exporter Metrics**: `http://<host>:9100/metrics`

### Logging
- **System Logs**: `journalctl` (systemd journal)
- **Network Services**: application-specific logs in `/var/log/`

---

## Safety & Best Practices

### Before Any Change
1. Diagnose the issue thoroughly
2. Explain the change and expected outcome
3. Warn about potential side effects
4. Request confirmation for risky changes
5. Document the change for audit trail

### Avoiding Common Mistakes
- Don't block SSH access (risk of lockout)
- Don't modify default route without understanding impact
- Don't disable monitoring during troubleshooting
- Test firewall rules before committing complex changes
- Verify routing doesn't create loops

### Logging & Auditability
- All significant changes logged with timestamp and reason
- Firewall changes tracked (config files and command history)
- VPN changes documented for troubleshooting
- DNS changes recorded with justification

---

## Naming Conventions (To Be Established)

Current: Ad-hoc based on device type and IP address
- Gateway: 24.204.72.65
- WireGuard Peer Example: 24.204.72.67

**Recommended Future Conventions**:
- Devices: `[type]-[function]-[index]` (e.g., `gw-primary-01`, `switch-core-01`)
- Services: `[service]-[location]` (e.g., `dns-gateway`, `mon-prometheus`)
- VLANs: `vlan-[purpose]-[number]` (if needed)
- Firewall Rules: Tag with service/purpose for easy filtering

---

## Reference Implementation

**Live Examples:**
- `DOCKER_AGENT_SKILLS.md` - Service port coordination, jumpbox SSH access
- `PROMETHEUS_AGENT_SKILLS.md` - Monitoring port ranges, scrape target configuration
- `WIREGUARD_AGENT_SKILLS.md` - VPN peer management, handshake monitoring, iptables coordination
- `SAMBA_AGENT_SKILLS.md` - SMB file sharing ports, container-to-share network paths
- Firewall rules at `/etc/ufw/` (live rule examples)
- iptables rules visible via `sudo iptables -L -n -v` (MASQUERADE, FORWARD chains)

**Cross-Agent Coordination Patterns:**
1. **Service Port Management** (Docker Agent → Network Agent):
   - Docker Agent defines service ports (2222 jumpbox, 5000-5999 prod, 8000-8999 dev)
   - Network Agent verifies firewall allows traffic to these ports
   - Communication: Docker service labels → Network Agent firewall rules

2. **Monitoring Infrastructure** (Prometheus Agent ↔ Network Agent):
   - Prometheus Agent scrapes metrics on 9100, 9090, 9093 ports
   - Network Agent ensures firewall allows scrape traffic
   - Network Agent ensures monitoring ports are only accessible from internal network
   - Communication: Prometheus scrape config → Network Agent firewall validation

3. **VPN Peer Management** (WireGuard Agent ↔ Network Agent):
   - WireGuard Agent manages peer configs and handshakes
   - Network Agent ensures port 51820/udp is open for external peers
   - Network Agent maintains iptables MASQUERADE for wg0 → wg-mullvad chaining
   - Network Agent verifies firewall allows peer-to-peer traffic within 24.204.72.64/26
   - Communication: Peer IP allocations → Network Agent iptables rules

4. **DNS Resolution** (All Agents → Network Agent):
   - All agents resolve peer names via Pi-hole at 24.204.72.65
   - Network Agent ensures DNS port 53 is accessible from all peers
   - Network Agent verifies Pi-hole upstream resolvers are configured
   - Communication: Network Agent maintains Pi-hole configuration

---

## Validation Checklist

Before implementing network changes, verify:

- [ ] All firewall rules are coordinated with affected agents (Docker, Prometheus, WireGuard)
- [ ] Port ranges match service definitions (dev 8000-9999, prod 5000-5999, jumpbox 2222)
- [ ] WireGuard peer IPs are within 24.204.72.64/26 allocation
- [ ] iptables rules are in place for VPN chaining (MASQUERADE, FORWARD)
- [ ] DNS resolution works from all network segments
- [ ] Pi-hole is accessible and upstream resolvers configured
- [ ] Prometheus can scrape monitoring targets (ports 9090, 9093, 9100 accessible)
- [ ] SSH key-based authentication is enforced (no password auth)
- [ ] All significant changes are logged for audit trail
- [ ] Routing tables don't contain loops (verify with `ip route show` on all nodes)
- [ ] External network connectivity works (test with `ping 8.8.8.8` or similar)
- [ ] VPN chaining functional (wg0 traffic exits through wg-mullvad correctly)

---

## Integration with Copilot Instructions

This file complements `.github/copilot-instructions.md` by providing agent-specific operational details. The copilot instructions provide project overview; this file defines agent autonomous capabilities and constraints.

---

## Future Enhancements

- [ ] Establish formal naming conventions
- [ ] Document all firewall rule purposes and groupings
- [ ] Create runbooks for common troubleshooting scenarios
- [ ] Add SNMP monitoring for network devices (switches, routers)
- [ ] Integrate with ticketing system for automated issue creation
- [ ] Setup alerting thresholds for latency, packet loss
- [ ] Document backup/restore procedures for network configs
