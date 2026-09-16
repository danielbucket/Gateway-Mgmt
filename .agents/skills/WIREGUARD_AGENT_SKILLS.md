# WireGuard Agent Skills

## Overview
This document defines the capabilities and responsibilities of the WireGuard Agent for the gateway-mgmt infrastructure. The agent manages VPN configuration, peer connectivity, key rotation, and network tunneling across physical machines and Docker containers. The agent operates in a hub-and-spoke topology where a gateway server (24.204.72.65) manages a local mesh network via `wg0` interface, chains to external Mullvad VPN via `wg-mullvad`, and coordinates with Docker Swarm for container-level VPN access and jumpbox tunneling. The agent monitors peer health, auto-recovers stale connections, and integrates with Prometheus for metrics and alerting.

---

## WireGuard Infrastructure Context

### Core Infrastructure
- **Gateway Server**: 24.204.72.65 (hub node, manages wg0 mesh network)
- **Local Mesh Network**: 24.204.72.64/26 (wg0 interface, ListenPort 51820/udp)
- **Mesh Peers**: 4 current peers (Gateway, SpaceBase, hyperdrive, Laboratory) on 24.204.72.65-24.204.72.68
- **VPN Chaining**: wg0 (local mesh) → wg-mullvad (external Mullvad VPN)
- **Routing**: PostUp/PostDown iptables rules manage MASQUERADE for traffic forwarding through Mullvad
- **DNS**: Pi-hole at 24.204.72.65 (DNS resolution for all peers)
- **Persistent Keepalive**: 25 seconds (maintain peer connectivity through NAT)

### Interfaces
- **wg0**: Local WireGuard mesh network interface
  - Address: 24.204.72.65/24
  - Port: 51820/udp
  - Role: Hub for peer connections; traffic forwarded to Mullvad
- **wg-mullvad**: Mullvad VPN chain interface
  - Role: External privacy layer; receives traffic from wg0
  - MASQUERADE rules applied: All wg0 traffic exits through Mullvad

### Peer Configuration
- **Naming Convention**: Peer names follow format `[DeviceName]` (Gateway, SpaceBase, hyperdrive, Laboratory)
- **Peer Storage**: `/etc/wireguard/peers/[PEER_NAME].conf` (encrypted files)
- **Peer Assignment**: Sequential IPs in 24.204.72.64/26 (24.204.72.65, 24.204.72.66, 24.204.72.67, 24.204.72.68, ...)
- **Backup Location**: `/var/backups/wireguard/peers/` (coordinated with Prometheus backups)
- **Key Format**: Base64-encoded 32-byte Curve25519 keys (WireGuard standard)

### Key Management
- **Key Generation**: Curve25519 cryptography; 32-byte base64-encoded private/public keys
- **Key Rotation**: On-demand only; secure distribution mechanism via encrypted files
- **Rotation Procedure**: Generate new key pair, update peer config, distribute encrypted config, peer updates their device, gateway validates handshake
- **Key Storage**: Private keys stored only on peer devices; public keys in gateway wg0.conf

### Integration Points
- **Network Agent**: Firewall rules (port 51820/udp), iptables MASQUERADE rules, routing coordination
- **Prometheus Agent**: Metrics export via custom script, handshake monitoring, stale connection alerts, peer offline detection
- **Docker Swarm Agent**: Jumpbox container VPN access, container-to-container tunneling, Docker network integration with wg0
- **Mullvad VPN**: External VPN chaining; agent monitors wg-mullvad interface health

### Monitoring & Observability
- **Prometheus Metrics**: Custom exporter script outputs handshake age, bytes sent/received, peer state
- **Metrics Export**: `node_exporter` compatible format (via `/usr/local/bin/wireguard-exporter.sh` script)
- **Handshake Monitoring**: Scrape interval 15 seconds (via Prometheus Agent)
- **Stale Detection**: Handshake age >180 seconds (3 minutes) triggers auto-recovery alert
- **Offline Detection**: Ping peer endpoint; log and alert if unreachable
- **Log Aggregation**: Prometheus receives WireGuard metrics; central logging via node_exporter

---

## Skill Areas

### 1. Peer Management Skill

**Responsibilities:**
- Add new peers to the WireGuard mesh network
- Remove peers (with confirmation and backup)
- Generate and distribute peer credentials securely
- Maintain peer configuration registry and naming conventions
- Manage peer IP address allocation

**Capabilities:**
- Generate key pair: `wg genkey | tee privatekey | wg pubkey > publickey`
- Create peer config file: Edit `/etc/wireguard/peers/[PEER_NAME].conf` with private key, peer name, assigned IP
- Add peer to gateway wg0.conf: Add `[Peer]` section with public key, AllowedIPs, PersistentKeepalive=25
- Encrypt peer config: `gpg --encrypt -r [RECIPIENT_KEY] /etc/wireguard/peers/[PEER_NAME].conf`
- Verify peer config: `sudo wg show wg0` (list all active peers with handshake status, bytes, endpoints)
- List all peers: `ls /etc/wireguard/peers/` (enumerate all peer configs)
- Query peer status: `sudo wg show wg0 peers`, `sudo wg show wg0 endpoints`, `sudo wg show wg0 latest-handshakes`
- Remove peer: Backup config, remove from wg0.conf, reload interface (requires confirmation)
- Assign next available IP: Track 24.204.72.65-24.204.72.126 (255 is broadcast); find first available

**Key Interfaces/Endpoints:**
- WireGuard interface: `wg0` (read config, add/remove peers)
- Config files: `/etc/wireguard/wg0.conf` (main config), `/etc/wireguard/peers/[PEER_NAME].conf` (peer configs)
- Backup location: `/var/backups/wireguard/peers/` (peer config backups)
- Encryption: GPG encryption for peer configs before distribution

**Environment Variables/Config:**
- Peer naming: `[DeviceName]` format (e.g., SpaceBase, hyperdrive, Laboratory)
- Peer IP range: 24.204.72.64/26 (24.204.72.65 = gateway, 24.204.72.66+ = peers)
- Config format: Standard WireGuard config [Interface] and [Peer] sections
- Encryption format: GPG-encrypted files (requires recipient public key)
- Persistent Keepalive: Always 25 seconds (maintain NAT traversal)

**Example Tasks:**
- Add new peer "bucketlab" with automatic IP assignment ( 24.204.72.69)
- Generate encrypted peer config for new device
- Remove peer "old-device" with confirmation and backup
- List all connected peers and their handshake status
- Verify new peer connectivity after joining mesh

**Constraints:**
- Peer addition requires unique name (no duplicates)
- Peer IP assignment must be sequential and unique (no conflicts)
- Require explicit confirmation before removing any peer (ask: "Remove peer [NAME] from mesh?")
- Always backup peer config before removal
- Peer configs must be encrypted before distribution (no plaintext transmission)
- Do NOT manually edit wg0.conf without coordination (use agent to manage)
- Peer name length: 1-50 characters (alphanumeric, hyphen, underscore only)

---

### 2. Interface Configuration & Zero-Downtime Updates Skill

**Responsibilities:**
- Configure WireGuard interfaces (wg0, wg-mullvad)
- Apply configuration changes without disrupting active connections
- Manage iptables rules for traffic forwarding and MASQUERADE
- Coordinate interface reloads with peer notifications
- Validate configuration syntax before deployment

**Capabilities:**
- View interface config: `sudo wg show wg0` (summary), `sudo cat /etc/wireguard/wg0.conf` (full config)
- Apply config changes: `sudo wg set wg0 [PEER] [ATTRIBUTE=VALUE]` (zero-downtime update)
- Reload interface: `sudo wg-quick down wg0 && sudo wg-quick up wg0` (downtime required for major changes)
- Verify iptables rules: `sudo iptables -t nat -L POSTROUTING | grep wg0`, `sudo iptables -L FORWARD | grep wg0`
- Apply routing rules: `sudo iptables -A FORWARD -i wg0 -j ACCEPT; sudo iptables -t nat -A POSTROUTING -o wg-mullvad -j MASQUERADE`
- Validate config syntax: Parse wg0.conf for required fields, correct format
- Backup config: `cp /etc/wireguard/wg0.conf /var/backups/wireguard/wg0.conf.$(date +%Y%m%d)`
- Restore config: `cp /var/backups/wireguard/wg0.conf.[DATE] /etc/wireguard/wg0.conf`

**Key Interfaces/Endpoints:**
- WireGuard config: `/etc/wireguard/wg0.conf`, `/etc/wireguard/wg-mullvad.conf`
- iptables configuration: System firewall rules (coordinated with Network Agent)
- Interface management: `wg`, `wg-quick`, `ip link` commands
- Systemd service: `systemctl status wg-quick@wg0` (interface startup)

**Environment Variables/Config:**
- PostUp/PostDown rules: MASQUERADE traffic from wg0 to wg-mullvad
- Interface address: 24.204.72.65/24 (gateway server)
- Interface port: 51820/udp (WireGuard listen port)
- PrivateKey: Stored in wg0.conf (read-only by root)
- DNS configuration: Point to Pi-hole at 24.204.72.65

**Example Tasks:**
- Update peer's AllowedIPs without disconnecting (use `wg set` for zero-downtime)
- Add iptables rule for new peer traffic forwarding
- Validate wg0.conf syntax before reloading
- Backup current wg0.conf before major configuration change
- Restore wg0.conf from backup if needed

**Constraints:**
- Changes to ListenPort or PrivateKey require full interface reload (downtime)
- Minor peer updates (AllowedIPs, PersistentKeepalive) use `wg set` (zero-downtime)
- All iptables changes must be coordinated with Network Agent
- Do NOT modify PrivateKey without explicit request (represents gateway identity)
- Configuration changes require validation before deployment
- Backup must exist before any major change
- PostUp/PostDown rules must remain to maintain wg0 → wg-mullvad chaining

---

### 3. Key Rotation & Credential Management Skill

**Responsibilities:**
- Generate and rotate peer cryptographic keys
- Securely distribute new keys to peers
- Validate key format and strength
- Maintain key version history
- Support secure key recovery/recovery procedures

**Capabilities:**
- Generate private key: `wg genkey` (Curve25519, 32-byte base64)
- Derive public key: `wg pubkey < privatekey > publickey`
- Create keypair: `wg genkey | tee privatekey | wg pubkey > publickey`
- Encrypt peer config for distribution: `gpg --encrypt -r [RECIPIENT] [CONFIG_FILE]`
- Decrypt received config: `gpg --decrypt [ENCRYPTED_CONFIG]`
- Validate key format: Check base64 encoding, 32-byte length, valid characters
- Update peer key in wg0.conf: Modify public key value for target peer
- Apply key update: `wg set wg0 [PEER_PUBKEY] PublicKey=[NEW_PUBKEY]` (zero-downtime)
- Verify handshake after key change: `sudo wg show wg0 latest-handshakes` (should show recent timestamp)

**Key Interfaces/Endpoints:**
- Key generation: `wg genkey`, `wg pubkey` commands
- Encryption: GPG with recipient key (coordinator's public key required)
- Peer config files: `/etc/wireguard/peers/[PEER_NAME].conf` (encrypted)
- Backup: `/var/backups/wireguard/peers/` (previous versions)

**Environment Variables/Config:**
- Key type: Curve25519 elliptic curve
- Key format: Base64-encoded 32-byte keys
- Rotation policy: On-demand only (no automatic rotation schedule)
- Distribution: GPG-encrypted files via secure channel
- Versioning: Keep previous key as backup for 30 days (rollback capability)

**Error Handling:**
- If key distribution fails: Retain old key until new key confirmed active
- If peer can't decrypt config: Ask peer to provide public GPG key; re-encrypt
- If wrong key deployed: Revert to previous key version, regenerate correct key
- If key validation fails: Reject deployment; regenerate and revalidate

**Example Tasks:**
- Rotate key for peer "SpaceBase" (security breach scenario)
- Generate new keypair for peer addition
- Encrypt peer config for secure distribution
- Verify handshake established with new key (after peer updates)
- Rollback to previous key if new key has issues

**Constraints:**
- Key rotation is on-demand only (no scheduled rotation)
- Require explicit approval before rotating any peer's key
- Encrypted peer configs must use GPG encryption (no plaintext)
- Peer must update their device config with new key (agent cannot push to peer)
- Old keys must be retained for rollback (keep 30 days minimum)
- Do NOT rotate gateway server key (wg0 PrivateKey) without major security incident
- Key rotation should be logged in Prometheus Agent

---

### 4. Connectivity Monitoring & Health Checks Skill

**Responsibilities:**
- Monitor peer connectivity status (handshakes, bytes transferred)
- Detect stale connections and offline peers
- Export metrics for Prometheus monitoring
- Diagnose connectivity issues between peers
- Provide real-time and historical connectivity status

**Capabilities:**
- Query peer handshake status: `sudo wg show wg0 latest-handshakes` (timestamp per peer)
- Calculate handshake age: `(current_time - handshake_timestamp)` (seconds)
- Query bytes transferred: `sudo wg show wg0 transfer` (bytes in/out per peer)
- Query peer endpoints: `sudo wg show wg0 endpoints` (current peer IP:port)
- Query peer allowed IPs: `sudo wg show wg0 allowed-ips`
- Check interface status: `ip link show wg0` (UP/DOWN state)
- Ping peer endpoint: `ping -c 1 [PEER_ENDPOINT_IP]` (ICMP connectivity)
- Export metrics: Execute `/usr/local/bin/wireguard-exporter.sh` (Prometheus format)
- Query metrics from script: Metrics output: handshake_age_seconds, bytes_sent, bytes_received, peer_state
- Monitor multiple peers simultaneously: Aggregate all peer metrics

**Key Interfaces/Endpoints:**
- WireGuard status: `wg show [INTERFACE]` (query all peer data)
- Custom exporter: `/usr/local/bin/wireguard-exporter.sh` (Prometheus metrics)
- Prometheus scrape: `http://[GATEWAY]:9100/metrics` (via node_exporter)
- ICMP connectivity: `ping [PEER_ENDPOINT]`
- Logs: `/var/log/wireguard-monitor.log` (monitoring script logs)

**Environment Variables/Config:**
- Handshake age threshold: <180 seconds = healthy; >=180 seconds = alert
- Persistent Keepalive: 25 seconds (peer initiates keepalive to maintain connection through NAT)
- Metric export interval: 15 seconds (Prometheus scrape interval)
- Metric format: Prometheus text format (HELP, TYPE, metric_name{labels} value)
- Offline detection: Ping endpoint if handshake stale; log if unreachable

**Example Tasks:**
- Query current handshake age for all peers
- Export WireGuard metrics in Prometheus format
- Detect peer "hyperdrive" offline (no recent handshake, ping fails)
- Monitor bytes transferred per peer (capacity planning)
- Alert if any peer handshake age >3 minutes (Prometheus alert rule)

**Constraints:**
- Handshake query requires root access (`sudo wg show`)
- Peer endpoint ping may fail through NAT (not definitive offline indicator)
- Metrics export must be in Prometheus format (for node_exporter integration)
- Do NOT modify peer state based on metrics alone (confirmation required)
- Keep peer configs even if offline (do not auto-remove)
- Monitor only active WireGuard interfaces (wg0, wg-mullvad)

---

### 5. Auto-Recovery & Stale Connection Handling Skill

**Responsibilities:**
- Detect stale peer handshakes (>180 seconds)
- Attempt automatic interface recovery (restart)
- Log recovery attempts and outcomes
- Alert to Prometheus on failed recovery
- Coordinate with Network Agent if manual intervention needed

**Capabilities:**
- Detect stale handshake: Compare current_time - latest_handshake > 180 seconds
- Restart WireGuard interface: `sudo wg-quick down wg0 && sleep 2 && sudo wg-quick up wg0`
- Restart via zero-downtime: `sudo wg syncconf wg0 <(sudo wg-quick strip wg0)` (attempt minimal restart)
- Verify recovery: `sudo wg show wg0 latest-handshakes` (should show recent timestamp after restart)
- Log recovery attempt: Write to `/var/log/wireguard-monitor.log` with timestamp and outcome
- Check Mullvad chain health: `sudo wg show wg-mullvad` (verify chaining still intact)
- Verify iptables rules post-recovery: `sudo iptables -t nat -L POSTROUTING | grep wg0`
- Alert to Prometheus: Increment `wireguard_recovery_attempts` counter metric

**Key Interfaces/Endpoints:**
- WireGuard interface restart: `wg-quick` commands
- Monitoring script: `/usr/local/bin/wireguard-monitor.sh` (runs periodically)
- Logs: `/var/log/wireguard-monitor.log` (recovery attempts and outcomes)
- Prometheus metrics: `wireguard_recovery_attempts`, `wireguard_recovery_failures`
- Mullvad interface: `wg-mullvad` (verify chaining after recovery)

**Environment Variables/Config:**
- Stale handshake threshold: 180 seconds (3 minutes)
- Recovery action: Restart interface (wg-quick down/up)
- Recovery interval: Check every 15 seconds (Prometheus scrape interval)
- Retry limit: Attempt recovery 3 times; alert if 3rd attempt fails
- Log retention: Keep logs for 30 days (coordinated with Prometheus)
- Mullvad verification: Check wg-mullvad is still UP after recovery

**Error Handling:**
- If recovery attempt fails: Log failure, alert to Prometheus, do not retry immediately
- If Mullvad chain broken after recovery: Alert to Network Agent, flag as critical
- If peer still offline after recovery: Log as "recovery inconclusive"; keep monitoring
- If iptables rules missing post-recovery: Reapply rules via Network Agent coordination

**Example Tasks:**
- Detect stale handshake for peer "Gateway" (handshake_age = 200 seconds)
- Attempt interface recovery: Restart wg0
- Verify recovery successful: New handshake timestamp should be recent
- Log recovery attempt: "Stale handshake detected (200s); recovery successful"
- Alert to Prometheus: `wireguard_recovery_attempts_total{interface="wg0"} = 1`

**Constraints:**
- Do NOT attempt recovery on every stale handshake detection (retry backoff needed)
- Recovery requires full interface restart (brief connectivity loss)
- Do NOT skip Mullvad chain verification (ensure chaining not broken)
- Maximum 3 recovery attempts before escalation to manual intervention
- If recovery fails 3 times, alert to Prometheus with `severity=critical`
- Keep peer configs intact even after failed recovery (do not remove)

---

### 6. Docker Swarm VPN Integration & Container Tunneling Skill

**Responsibilities:**
- Manage VPN access for Docker containers (jumpbox, services)
- Configure container-level network tunneling to WireGuard mesh
- Coordinate container network policies with peer policies
- Manage VPN credentials for containers
- Monitor container-to-peer connectivity

**Capabilities:**
- Verify jumpbox container connectivity: `docker exec jumpbox wg show` (if wg tools available)
- Create container VPN tunnel: Configure Docker service to use wg0 network bridge
- Mount WireGuard config in container: `docker volume mount /etc/wireguard:/etc/wireguard:ro`
- Query container network status: `docker inspect [CONTAINER] | grep Network`
- Configure container environment: Set VPN endpoint via environment variable
- Verify container DNS resolution: `docker exec [CONTAINER] nslookup [PEER_NAME]` (via Pi-hole)
- Ping peer from container: `docker exec [CONTAINER] ping [PEER_IP]` (test connectivity)
- Monitor container VPN bandwidth: Query Prometheus for container network I/O metrics
- Manage container credentials: Store VPN keys in encrypted Docker volumes

**Key Interfaces/Endpoints:**
- Docker service configuration: Docker Compose or `docker service create` with network config
- Container networking: Bridge network to wg0 (coordinated with Docker Agent)
- Volume mounts: `/etc/wireguard/` (read-only for containers)
- Environment variables: VPN endpoint, peer names, DNS server (24.204.72.65)
- Jumpbox container: SSH access to internal services via wg0 tunnel

**Environment Variables/Config:**
- Container DNS: Point to 24.204.72.65 (Pi-hole)
- Container network: Bridge to wg0 (not host network)
- VPN credential injection: Via encrypted environment files (coordinated with Docker Agent)
- Container labels: `wireguard_enabled=true` for monitoring
- Jumpbox service: Provides authenticated SSH tunneling to wg0 peers

**Example Tasks:**
- Configure jumpbox container to access wg0 mesh network
- Enable Docker service to route traffic through WireGuard peer
- Verify container can reach peer via wg0 tunnel (ping, nslookup)
- Monitor container-to-peer bandwidth usage
- Update container VPN credentials when peer key is rotated

**Constraints:**
- Container VPN access requires jumpbox or proxy service (no direct WireGuard container support)
- Do NOT expose WireGuard private keys in container logs
- Container network isolation: Only allow traffic to authorized peers
- Coordinate with Docker Agent for service deployment (network policies)
- Coordinate with Network Agent for firewall rules (container-to-peer traffic)
- Keep container VPN configs in sync with gateway wg0.conf

---

### 7. Prometheus Exporter Script Management Skill

**Responsibilities:**
- Maintain `/usr/local/bin/wireguard-exporter.sh` script for Prometheus metrics
- Execute exporter script on 15-second intervals (Prometheus scrape window)
- Ensure metric output matches Prometheus expectations
- Coordinate script updates with Prometheus Agent
- Monitor exporter process health

**Capabilities:**
- Execute exporter script: `/usr/local/bin/wireguard-exporter.sh` (output Prometheus format)
- Verify script permissions: `ls -l /usr/local/bin/wireguard-exporter.sh` (must be executable)
- Check script output format: Metrics must include `# HELP` and `# TYPE` lines per Prometheus spec
- Validate metric names: `wireguard_peer_*` prefix, peer_name labels from wg0.conf
- Test exporter execution: Run script manually and verify output
- Monitor exporter stderr: Check `/var/log/wireguard-exporter.log` for errors
- Update script on peer changes: Re-export metric labels when peers added/removed
- Coordinate with Prometheus Agent: Notify when exporter output format changes
- Verify backward compatibility: New exporter version must support previous metric names

**Key Interfaces/Endpoints:**
- Exporter script: `/usr/local/bin/wireguard-exporter.sh`
- Script ownership: Executable by `prometheus` user (UID 65534)
- Execution user: Run via `node_exporter` textfile collector or direct scrape
- Output format: Prometheus text format (metrics with HELP/TYPE documentation)
- Log file: `/var/log/wireguard-exporter.log` (script stderr/stdout)
- Prometheus scrape: Exporter metrics included in `http://24.204.72.65:9090/metrics`

**Environment Variables/Config:**
- Exporter script path: `/usr/local/bin/wireguard-exporter.sh`
- Execution interval: 15 seconds (synchronized with Prometheus scrape interval)
- Script timeout: 10 seconds maximum (prevent blocking scrape cycle)
- Metric labels: Must include `peer_name` (from peer config), `interface` (wg0/wg-mullvad)
- Output destination: stdout (captured by Prometheus or node_exporter textfile collector)
- Script permissions: 755 (executable), owner root:root, group prometheus read access

**Example Tasks:**
- Execute exporter script and verify Prometheus metric format
- Add new peer "Laboratory" to exporter output (update peer_name labels)
- Update exporter script to include wg-mullvad metrics
- Test exporter backward compatibility (old Prometheus queries still work)
- Monitor exporter execution time (ensure <10 second timeout)

**Constraints:**
- Exporter output must be valid Prometheus format (fails if invalid)
- Script must complete within 10 seconds (prevent Prometheus scrape backlog)
- Peer names in labels must exactly match wg0.conf peer names (case-sensitive)
- Do NOT modify exporter script without Prometheus Agent notification
- Exporter script changes require backward compatibility validation
- Keep exporter script in version control `/usr/local/bin/wireguard-exporter.sh`

---

### 8. VPN Chaining & Mullvad Integration Skill

**Responsibilities:**
- Monitor wg-mullvad interface health and connectivity
- Maintain VPN chaining configuration (wg0 → wg-mullvad)
- Detect and alert on chain breakage
- Coordinate iptables rules for traffic routing
- Manage fallback or recovery procedures if chaining breaks

**Capabilities:**
- Query Mullvad interface status: `sudo wg show wg-mullvad` (interface UP/DOWN, peer status)
- Verify chain configuration: Check iptables MASQUERADE rule exists for wg0 → wg-mullvad
- Monitor Mullvad handshake: `sudo wg show wg-mullvad latest-handshakes` (peer connectivity)
- Test traffic through chain: Ping external IP via wg0 (verifies full chain working)
- Verify iptables rules: `sudo iptables -t nat -L POSTROUTING | grep "wg-mullvad"`
- Apply chaining rules: Execute PostUp rules in wg0.conf (MASQUERADE configuration)
- Restart chaining: `sudo wg-quick down wg0 && sudo wg-quick down wg-mullvad && sudo wg-quick up wg-mullvad && sudo wg-quick up wg0`
- Export chain health metrics: Include wg-mullvad handshake age in Prometheus exporter script
- Diagnose chain breakage: Check wg-mullvad status, verify iptables rules, test external connectivity

**Key Interfaces/Endpoints:**
- Mullvad interface: `wg-mullvad` (external VPN)
- Configuration: PostUp/PostDown rules in wg0.conf (traffic forwarding)
- iptables verification: `sudo iptables -t nat -L POSTROUTING`, `sudo iptables -L FORWARD`
- External test: `ping 8.8.8.8` via wg0 (verifies chain to external internet)
- Prometheus metrics: Include `wireguard_mullvad_handshake_age_seconds` in exporter

**Environment Variables/Config:**
- PostUp rule: `iptables -t nat -A POSTROUTING -o wg-mullvad -j MASQUERADE`
- PostDown rule: `iptables -t nat -D POSTROUTING -o wg-mullvad -j MASQUERADE`
- FORWARD rule: `iptables -A FORWARD -i wg0 -j ACCEPT` (allow wg0 traffic)
- Chain health threshold: wg-mullvad handshake <180 seconds = healthy
- Fallback: If chain broken, alert immediately (do not attempt auto-restart without confirmation)

**Error Handling:**
- If Mullvad interface down: Alert to Prometheus; do not attempt auto-recovery (requires Mullvad service check)
- If iptables rules missing: Reapply PostUp rules; verify with Network Agent
- If chain broken but interfaces UP: Check external connectivity; diagnose routing issue
- If full restart needed: Coordinate with Network Agent for firewall rule timing

**Example Tasks:**
- Monitor Mullvad handshake age (alert if >3 minutes)
- Verify wg0 traffic successfully exits via wg-mullvad
- Detect iptables MASQUERADE rule missing (alert if not present)
- Restart entire chain if needed (wg0 + wg-mullvad + iptables)
- Test external connectivity: `curl https://api.mullvad.net/ip` (verify IP is from Mullvad)

**Constraints:**
- Do NOT modify Mullvad interface config without explicit request (Mullvad service managed externally)
- Chain breakage is critical alert (escalate immediately to Prometheus Agent)
- iptables rule changes must be coordinated with Network Agent
- Do NOT attempt recovery for wg-mullvad if Mullvad service is down (different issue)
- Verify chain post-recovery: External IP should resolve to Mullvad provider
- Keep wg-mullvad interface UP at all times (critical for privacy)

---

### 9. Offline Peer Detection & Logging Skill

**Responsibilities:**
- Detect when peers go offline (no handshake, unreachable endpoint)
- Log offline events with timestamps and context
- Ping offline peers to confirm status
- Maintain peer status history
- Alert to Prometheus on peer offline events

**Capabilities:**
- Detect stale handshake: `handshake_age > 180 seconds` indicates likely offline
- Ping peer endpoint: `ping -c 1 [PEER_ENDPOINT_IP]` (confirm unreachable)
- Query peer endpoint: `sudo wg show wg0 endpoints` (see current endpoint for peer)
- Log offline event: Write to `/var/log/wireguard-monitor.log` with peer name, timestamp, handshake age
- Check peer config: Verify peer still in wg0.conf (do NOT remove offline peers)
- Query offline history: Grep logs for peer offline events over time
- Calculate peer uptime: Aggregate online/offline events over period
- Alert to Prometheus: Increment `wireguard_peer_offline_total` counter metric
- Export peer status: Include in metrics export (peer_state: online/offline/unknown)

**Key Interfaces/Endpoints:**
- Handshake query: `sudo wg show wg0 latest-handshakes`
- Ping endpoint: ICMP to peer's endpoint IP
- Logging: `/var/log/wireguard-monitor.log`
- Prometheus metrics: `wireguard_peer_offline_total`, `wireguard_peer_state`
- Config file: `/etc/wireguard/wg0.conf` (peer verification)

**Environment Variables/Config:**
- Offline detection criteria: Handshake age >180 seconds AND ping fails
- Log format: `[TIMESTAMP] ⚠️ OFFLINE: [PEER_NAME] (IP: [PEER_IP], handshake_age: [AGE]s, ping: FAIL)`
- Offline retry: Ping 2-3 times before confirming offline
- Peer retention: Keep offline peer in wg0.conf (do not auto-remove)
- Metrics retention: Keep offline events in Prometheus logs (30 days minimum)
- Status persistence: Remember peer was offline across monitoring cycles

**Example Tasks:**
- Detect peer "SpaceBase" offline (handshake_age = 300 seconds, ping fails)
- Log offline event: "OFFLINE: SpaceBase (IP: 192.168.1.100, handshake_age: 300s, ping: FAIL)"
- Alert to Prometheus: `wireguard_peer_offline_total{peer="SpaceBase"} = 1`
- Maintain peer in wg0.conf (do not remove)
- Query offline history: Find all times peer was detected offline in logs

**Constraints:**
- Do NOT remove offline peers automatically (keep for reconnection)
- Ping may fail through NAT (not definitive offline proof)
- Log offline events with full context (peer name, IP, handshake age, ping result)
- Keep peer configs in backup even if offline (enable rejoining)
- Offline detection requires both stale handshake AND failed ping
- Do NOT escalate to critical alert for offline peer (informational only)
- Monitor should log offline peers at regular intervals (every 15 seconds) if still offline

---

## Diagnostic Workflows

### Peer Handshake Stale Troubleshooting
1. **Symptom**: Peer handshake age exceeds 3 minutes (180 seconds); possible connection stale
2. **Steps**:
   - Check handshake age: `sudo wg show wg0 latest-handshakes` (identify stale peer)
   - Calculate age: `(current_time - timestamp) / 60` (convert to minutes)
   - Ping peer endpoint: `ping -c 2 [PEER_ENDPOINT]` (test network path to peer)
   - If ping succeeds: Likely peer-side issue (firewall, WireGuard misconfiguration)
   - If ping fails: Network path broken; coordinate with Network Agent for firewall rules
   - Check iptables rules: Verify FORWARD and MASQUERADE rules still in place
   - Attempt auto-recovery: Restart wg0 interface via `wg-quick down/up`
   - Verify recovery: Check handshake timestamp refreshed to current time
   - Alert to Prometheus: Log recovery attempt and outcome
   - Recommend: Contact peer for device status; investigate peer-side WireGuard logs

### Peer Offline Detection Troubleshooting
1. **Symptom**: Peer offline (no recent handshake; unreachable)
2. **Steps**:
   - Query peer status: `sudo wg show wg0` (check latest-handshakes and endpoints)
   - Identify stale handshake: Age >180 seconds
   - Ping peer endpoint: `ping -c 3 [PEER_ENDPOINT_IP]` (test reachability)
   - If ping succeeds: Peer may be online but not communicating; ask peer to check WireGuard status
   - If ping fails: Peer appears offline or unreachable; log offline event
   - Check peer config: Verify peer still in wg0.conf (has not been removed)
   - Attempt recovery ping: Wait 30 seconds; ping again (transient issue?)
   - Log offline event: Write to log with timestamp, peer name, handshake age, ping result
   - Alert Prometheus: Increment offline counter; check for repeated offline/online cycles (flapping)
   - Recommend: Investigate peer device status; check peer network connectivity; verify peer WireGuard config

### Mullvad Chain Breakage Troubleshooting
1. **Symptom**: wg-mullvad interface down or no recent handshake (chaining broken)
2. **Steps**:
   - Check wg-mullvad status: `sudo wg show wg-mullvad` (interface UP/DOWN, handshake age)
   - If interface down: Mullvad VPN service issue; verify Mullvad daemon running
   - If interface up but stale handshake: Mullvad peer unreachable; test external connectivity
   - Verify iptables rules: `sudo iptables -t nat -L POSTROUTING | grep wg-mullvad` (MASQUERADE present?)
   - Test wg0 traffic through chain: `ping 8.8.8.8` via wg0 (should route through Mullvad)
   - If test fails: Check iptables FORWARD rules (should allow wg0 traffic)
   - Restart chain (if confirmed safe): `wg-quick down wg0 && wg-quick down wg-mullvad && wg-quick up wg-mullvad && wg-quick up wg0`
   - Verify recovery: Test external connectivity again
   - Alert critical: Chain breakage is critical; alert to Prometheus and escalate
   - Coordinate: Contact Mullvad service team if issue persists; check Mullvad VPN connectivity

### Key Rotation Verification Troubleshooting
1. **Symptom**: New peer key deployed; handshake not established (key mismatch or sync issue)
2. **Steps**:
   - Verify new public key deployed: Check wg0.conf for target peer (should show new key)
   - Confirm peer has new private key: Ask peer to verify their config has matching private key
   - Check handshake timestamp: `sudo wg show wg0 latest-handshakes` (should be recent after peer update)
   - If handshake timestamp is old: Peer may not have reloaded new key; ask peer to restart WireGuard
   - If handshake still not established: Verify peer public key matches gateway config exactly (copy-paste errors?)
   - Test with old key: Temporarily revert to old public key; verify handshake works (confirms key issue)
   - If old key works: New key may be corrupted; regenerate and re-distribute
   - Log verification: "Key rotation for [PEER_NAME]: Old key [TIME], New key [TIME], Handshake established [TIME]"
   - Alert Prometheus: Track key rotation success/failure metrics
   - Recommend: Double-check encryption/decryption of distributed peer config; verify peer key sync

### VPN Access from Container Troubleshooting
1. **Symptom**: Docker container cannot reach WireGuard peers (DNS fails, ping fails, or tunnel not working)
2. **Steps**:
   - Verify container network: `docker inspect [CONTAINER] | grep Network` (should connect to wg0 bridge)
   - Check container DNS: `docker exec [CONTAINER] nslookup [PEER_NAME]` (should resolve via Pi-hole 24.204.72.65)
   - If DNS fails: Verify Pi-hole is running; check /etc/resolv.conf in container (should have nameserver 24.204.72.65)
   - Ping peer from container: `docker exec [CONTAINER] ping [PEER_IP]` (test connectivity)
   - If ping succeeds: Container has network access; issue may be application-level
   - If ping fails: Check network routing inside container; verify wg0 bridge connectivity
   - Check firewall rules: Coordinate with Network Agent; verify container-to-peer traffic allowed
   - Restart container networking: `docker network disconnect wg0 [CONTAINER] && docker network connect wg0 [CONTAINER]`
   - Verify recovery: Retry DNS and ping tests
   - Recommend: Check container image has networking tools; verify network policy allows container-to-peer traffic

---

## Writing Best Practices

### Language & Tone
- **Be specific**: Use actual interface names (wg0, wg-mullvad), file paths, IP addresses, commands
- **Be concise**: Avoid lengthy explanations; use bullet points and examples
- **Be actionable**: Each capability should guide concrete WireGuard operations
- **Avoid ambiguity**: Clearly distinguish peer management, key operations, monitoring, recovery

### Structure Rules
1. **Headers**: Use descriptive H2-H4 headers (avoid H1 except title)
2. **Lists**: Use bullets for capabilities/constraints; numbers for diagnostic steps
3. **Code**: Wrap commands and paths in backticks (e.g., `` `wg show wg0` ``, `` `/etc/wireguard/peers/` ``)
4. **Bold**: Use bold only for section labels and key terms (e.g., `**Responsibilities:**`, `**handshake age**`)
5. **Terminology**: Define technical terms (handshake, keepalive, chaining, MASQUERADE) in context

### Anti-Patterns to Avoid
- ❌ Vague peer names (always use actual naming scheme: Gateway, SpaceBase, etc.)
- ❌ Missing command examples (show full `wg` and `iptables` commands)
- ❌ Incomplete key rotation workflow (show distribution, verification, rollback)
- ❌ No mention of backup locations (always specify `/var/backups/wireguard/peers/`)
- ❌ Unclear encryption requirements (specify GPG encryption for peer configs)
- ❌ No coordination points (always mention Network Agent, Prometheus Agent, Docker Agent)

### Best Practices
- ✓ Always backup peer configs before removal
- ✓ Test new peer connectivity immediately after adding
- ✓ Use `wg set` for zero-downtime updates whenever possible
- ✓ Encrypt peer configs before distribution (never plaintext)
- ✓ Log all peer changes (additions, removals, key rotations)
- ✓ Monitor handshake age continuously (Prometheus scraping every 15 seconds)
- ✓ Attempt recovery only for stale handshakes; coordinate for offline peers
- ✓ Verify Mullvad chain health regularly (critical for privacy)
- ✓ Keep offline peers in configuration (enable easy reconnection)
- ✓ Coordinate all interface changes with Network Agent for iptables rules

---

## Validation Checklist

Before performing WireGuard operations, verify:

- [ ] All peer names follow naming convention (e.g., Gateway, SpaceBase, hyperdrive)
- [ ] Peer IP assignments are sequential and unique (no duplicates in 24.204.72.64/26)
- [ ] Peer config files are encrypted (GPG) before distribution
- [ ] Peer backups exist in `/var/backups/wireguard/peers/`
- [ ] wg0.conf syntax is valid (all [Interface] and [Peer] sections correct)
- [ ] iptables MASQUERADE and FORWARD rules are in place
- [ ] wg-mullvad interface is UP and handshake is recent (<180 seconds)
- [ ] All peer handshakes are recent (<180 seconds)
- [ ] Prometheus exporter script is present and executable at `/usr/local/bin/wireguard-exporter.sh`
- [ ] Prometheus is scraping WireGuard metrics (handshake_age, bytes, peer_state)
- [ ] Docker containers can reach wg0 peers (via jumpbox or bridge)
- [ ] Offline peers are logged but NOT removed from configuration
- [ ] All changes are logged in `/var/log/wireguard-monitor.log`

---

## Reference Implementation

**Live Examples:**
- `NETWORK_AGENT_SKILLS.md` - Firewall rules coordination, iptables management
- `DOCKER_AGENT_SKILLS.md` - Jumpbox container, Docker networking, VPN access, service coordination
- `PROMETHEUS_AGENT_SKILLS.md` - Metrics collection, alerting, monitoring, exporter coordination
- `SAMBA_AGENT_SKILLS.md` - Jumpbox proxy for remote SMB access, container-based file sharing
- Current wg0.conf at `/etc/wireguard/wg0.conf` (live example)
- vpn-monitor.sh at `/home/empire/gateway-mgmt/wireguard/vpn-monitor.sh` (recovery reference)
- wireguard-exporter.sh at `/usr/local/bin/wireguard-exporter.sh` (Prometheus metrics generation)

**When adding a new peer:**
1. Generate keypair: `wg genkey | tee privatekey | wg pubkey > publickey`
2. Assign next available IP in 24.204.72.64/26 (check existing allocations)
3. Create encrypted peer config: Store in `/etc/wireguard/peers/[PEER_NAME].conf` (encrypted)
4. Add to wg0.conf: Add [Peer] section with public key, AllowedIPs, PersistentKeepalive=25
5. Reload interface: `wg set wg0` (zero-downtime) or `wg-quick up/down` (if needed)
6. Update Prometheus exporter script: Add peer_name to metric labels
7. Verify connectivity: Check handshake timestamp within 30 seconds (Prometheus metric: `wireguard_peer_latest_handshake_seconds`)
8. Distribute encrypted config to peer
9. Log addition in Prometheus Agent

**When integrating Docker services with WireGuard:**
1. Verify jumpbox container is running on wg0 bridge network (per Docker Agent config)
2. Ensure Docker service has appropriate network labels: `wireguard_enabled=true`
3. Verify container can reach wg0 peers via jumpbox (test: `docker exec [CONTAINER] ping [PEER_IP]`)
4. Update Prometheus exporter to include container network metrics
5. Verify container DNS resolution via Pi-hole: `docker exec [CONTAINER] nslookup gateway` should resolve to wg0 peer
6. Test container-to-peer SSH tunneling via jumpbox
7. Monitor container network I/O via Prometheus metrics: `container_network_transmit_bytes_total` per peer

**When rotating a peer key:**
1. Require explicit approval (security-sensitive operation)
2. Generate new keypair for peer
3. Encrypt new peer config
4. Distribute encrypted config to peer securely
5. Peer updates their device with new private key
6. Verify new handshake established after peer update
7. Keep old key as rollback backup for 30 days
8. Log rotation in Prometheus Agent (track rotation history)

**When monitoring WireGuard health:**
1. Query peer handshakes every 15 seconds (Prometheus scrape interval)
2. Export metrics via `/usr/local/bin/wireguard-exporter.sh`
3. Alert if any handshake age >180 seconds (attempt recovery)
4. Alert if wg-mullvad handshake stale (chain breakage)
5. Log offline peers; keep in configuration
6. Coordinate recovery attempts with Network Agent if needed

---

## Questions to Guide WireGuard Operations

When managing WireGuard, ask:

1. **What peer needs to be added/modified?** (Peer name, IP assignment, key rotation?)
2. **Is this peer a physical device or Docker container?** (Affects network integration strategy)
3. **Does the peer have current key material?** (Affects key distribution method)
4. **What is the peer's expected connectivity?** (Always-on, intermittent, NAT'd, etc.)
5. **Should this be zero-downtime?** (Use `wg set` if possible)
6. **What is the rollback plan?** (Keep old configs, peer backups, key rollback)
7. **Is Mullvad chaining still working?** (Always verify after changes)
8. **Do container workloads need VPN access?** (Coordinate with Docker Agent)
9. **What metrics should Prometheus monitor?** (Handshake age, bytes, peer state)
10. **Is this peer going offline or permanently removed?** (Log vs. delete decision)

Answer these for each operation, and you'll maintain secure, reliable WireGuard mesh connectivity.

---

**Last Updated**: September 15, 2026
**Version**: 1.0
**Network**: 24.204.72.64/26
**Interface Port**: 51820/udp
**Peers**: 4 active (Gateway, SpaceBase, hyperdrive, Laboratory)
**Chaining**: wg0 → wg-mullvad (Mullvad VPN)
