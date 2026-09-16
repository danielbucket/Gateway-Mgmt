# Prometheus Agent Skills

## Overview
This document defines the capabilities and responsibilities of the Prometheus Agent for the gateway-mgmt infrastructure. The agent manages metrics collection, alerting rules, data integrity, and backup/restore operations for the Prometheus monitoring system. The agent monitors Docker Swarm containers, network infrastructure (WireGuard peers, VPN health, DNS resolution), system metrics via node_exporter, and manages Alertmanager alert rules. The agent provides read-only access to metrics via API and web UI, restricted to the internal network (24.204.72.64/26).

---

## Prometheus Infrastructure Context

### Core Infrastructure
- **Prometheus Instance**: 24.204.72.65:9090 (API and web UI)
- **Storage Location**: Local disk (path: `/var/lib/prometheus/`)
- **Storage Limit**: 2GB maximum
- **Metric Retention**: 30 days
- **Scrape Interval**: 15 seconds
- **Alertmanager Instance**: Co-located with Prometheus (24.204.72.65:9093)
- **Access**: Internal network only (24.204.72.64/26); both API and web UI enabled
- **Authentication**: None (internal network restriction is primary security control)

### Key Services & Integration Points
- **Docker Swarm**: Scrapes container metrics from all 3 nodes (manager + 2 workers)
- **node_exporter**: System-level metrics on all swarm nodes (CPU, memory, disk, network I/O)
- **WireGuard Peers**: VPN metrics from wg0 and wg-mullvad interfaces on gateway
- **Pi-hole DNS**: DNS resolution and query metrics from 24.204.72.65
- **Alertmanager**: Alert rule management and alert history storage
- **Docker Logging Driver**: Container stdout/stderr sent to Prometheus (via Docker logging plugin)

### Monitoring Targets
- **Docker Swarm Nodes**: 3 targets (manager, worker1, worker2)
- **Docker Containers**: Dynamic discovery via Docker Swarm labels
- **WireGuard Peers**: 1 target per peer (query via `wg show` command)
- **VPN Health**: Handshake status, interface state, connectivity checks
- **DNS Resolution**: Pi-hole query metrics and resolution health
- **Network Infrastructure**: Firewall, routing, VPN tunnel statistics

### Alertmanager Configuration
- **Alert Storage**: In-memory history (no external notification backends currently)
- **Alert Rules Location**: `/etc/prometheus/rules/` (managed by agent)
- **Reload Method**: POST to `http://24.204.72.65:9090/-/reload` to hot-reload rules
- **Alert States**: Firing, Pending, Resolved (tracked by Alertmanager)

### Backup & Recovery
- **Backup Location**: `/var/backups/prometheus/`
- **Metrics Export Format**: Prometheus custom format (via `prom-tool`)
- **Alert Rules Backup**: YAML configuration files (text-based, version-controllable)
- **Restore Procedure**: Stop Prometheus, restore files, restart, validate integrity

---

## Skill Areas

### 1. Metrics Scraping & Target Management Skill

**Responsibilities:**
- Manage Prometheus scrape targets dynamically
- Configure scrape intervals (15 seconds for all targets)
- Add/remove scrape targets without restarting Prometheus
- Monitor scrape success rates and target health
- Diagnose scrape failures (connectivity, authentication, timeout)

**Capabilities:**
- Query Prometheus targets via API: `curl http://24.204.72.65:9090/api/v1/targets`
- Add scrape target via Prometheus configuration: Edit `prometheus.yml`, POST `/-/reload`
- Remove scrape target by updating configuration and reloading
- Check target health: Query `up` metric to see which targets are responding
- Monitor scrape duration: `scrape_duration_seconds` metric per target
- Identify scrape failures: Query `scrape_samples_post_metric_relabeling` for incomplete scrapes
- Test target connectivity: `ping [TARGET_IP]`, `curl [TARGET_ENDPOINT]` before adding
- View scrape configuration: `curl http://24.204.72.65:9090/api/v1/label/__meta_prometheus_job_name/values`

**Key Interfaces/Endpoints:**
- Prometheus targets API: `http://24.204.72.65:9090/api/v1/targets`
- Prometheus configuration reload: `POST http://24.204.72.65:9090/-/reload`
- Prometheus targets web UI: `http://24.204.72.65:9090/targets`
- Docker Swarm metrics: `http://[SWARM_NODE]:9100/metrics` (node_exporter)
- WireGuard metrics: Query `wg show [INTERFACE]` on gateway node
- Pi-hole metrics: Query DNS API or `/admin/api.php` on Pi-hole

**Environment Variables/Config:**
- Scrape config file: `/etc/prometheus/prometheus.yml`
- Scrape interval: 15 seconds (global default)
- Scrape timeout: 10 seconds (must be less than interval)
- Target labels: `job`, `instance`, `__meta_*` (for service discovery)
- Docker Swarm discovery: Labels `prometheus_scrape=true` on services trigger scraping

**Example Tasks:**
- Add new worker node (node_exporter) to scrape targets
- Remove failed swarm node from scrape targets after recovery
- Verify all 3 swarm nodes are reporting metrics within last 15 seconds
- Diagnose "node_exporter not responding" (check network, firewall, service status)
- Monitor scrape success rate: Alert if >5% of scrapes fail on any target

**Constraints:**
- Scrape interval is fixed at 15 seconds (do not modify without approval)
- Do NOT remove critical targets (swarm nodes, node_exporter, WireGuard) without confirmation
- Scrape timeout must be less than scrape interval (max 10 seconds)
- All scrape targets must be on internal network (24.204.72.64/26) or VPN-accessible
- Test target connectivity before adding to scrape configuration
- Coordinate with Network Agent if firewall rules needed for new target

---

### 2. Alert Rules Management Skill

**Responsibilities:**
- Create, update, and delete Prometheus alert rules
- Require approval before modifying alert rules (safety mechanism)
- Manage alert rule groups and organization
- Monitor alert firing status and history
- Validate alert rule syntax before deployment

**Capabilities:**
- List all alert rules: `curl http://24.204.72.65:9090/api/v1/rules` (includes alert status)
- Create alert rule: Edit `/etc/prometheus/rules/*.yml`, validate syntax, POST `/-/reload`
- Update alert rule: Modify `.yml` file, validate, reload Prometheus
- Delete alert rule: Remove from `.yml` file, reload Prometheus
- Validate rule syntax: `promtool check rules /etc/prometheus/rules/*.yml`
- Query firing alerts: `curl http://24.204.72.65:9090/api/v1/alerts`
- View alert history: Alertmanager API `http://24.204.72.65:9093/api/v1/alerts/groups`
- Test alert rule: Evaluate rule in Prometheus graph: `http://24.204.72.65:9090/graph`

**Key Interfaces/Endpoints:**
- Prometheus rules API: `http://24.204.72.65:9090/api/v1/rules`
- Prometheus alerts API: `http://24.204.72.65:9090/api/v1/alerts`
- Alertmanager API: `http://24.204.72.65:9093/api/v1/alerts`
- Alertmanager groups: `http://24.204.72.65:9093/api/v1/alerts/groups`
- Rule files location: `/etc/prometheus/rules/`

**Environment Variables/Config:**
- Alert rule format: YAML (groups, rules, expr, for, labels, annotations)
- Rule file naming: `[SERVICE]_alerts.yml` (e.g., `docker_alerts.yml`, `network_alerts.yml`)
- Alert severity levels: `critical`, `warning`, `info`
- Alert duration (`for` field): Minimum 1 minute before firing (prevent flapping)
- Rule reload: POST to `http://24.204.72.65:9090/-/reload` after modifying files

**Error Handling:**
- If rule syntax is invalid: `promtool` validation fails; fix YAML and retry
- If alert doesn't fire: Check metric exists (`curl http://24.204.72.65:9090/api/v1/query?query=[METRIC]`)
- If reload fails: Check Prometheus logs, verify rule files are readable (600+ permissions)
- If Alertmanager doesn't display alert: Verify rule has `alert:` label, check Alertmanager is running

**Example Tasks:**
- Create alert: "CPU >80%" for any container (metric: `container_cpu_usage_seconds_total`)
- Create alert: "Memory >90%" for production services (metric: `container_memory_usage_bytes`)
- Create alert: "Service down" if `up == 0` for any swarm node
- Create alert: "WireGuard handshake stale" if handshake age >3 minutes
- Update alert threshold: Change CPU threshold from 80% to 75%
- Delete obsolete alert rule: Remove alert for deprecated service

**Constraints:**
- **REQUIRE EXPLICIT APPROVAL** before creating, updating, or deleting any alert rule
- Alert syntax must be validated with `promtool` before deployment
- Alert rule `for` duration must be >= 1 minute (prevent flapping)
- Alert labels must include `severity` (critical, warning, info)
- Alert annotations must include `description` (explaining the alert)
- Do NOT create alerts that fire more than once per minute (tuning avoidance)
- All alert changes must be logged and tracked for audit trail

---

### 3. Docker Swarm & Container Metrics Skill

**Responsibilities:**
- Monitor container and service health metrics from Docker Swarm
- Track CPU, memory, network I/O, and disk usage per container
- Monitor service replica status and deployment health
- Query container logs aggregated by Prometheus
- Diagnose container performance issues from metrics
- Validate Docker logging driver configuration per Docker Agent specifications

**Capabilities:**
- Query container CPU usage: `container_cpu_usage_seconds_total` metric
- Query container memory usage: `container_memory_usage_bytes` metric
- Query container network I/O: `container_network_receive_bytes_total`, `container_network_transmit_bytes_total`
- Query container disk I/O: `container_fs_*` metrics
- List all containers: Query `container_names` label values
- Filter by service: Query metrics with `container_label_com_docker_swarm_service_name` label
- Distinguish prod vs dev: Query metrics with `container_label_environment` label (prod/dev)
- Query container logs: `container_stdout_lines` metric (aggregated by service)
- Monitor service replica status: Query `docker_service_replicas_*` metrics
- Track container restart count: `container_last_seen` metric combined with container creation time

**Key Interfaces/Endpoints:**
- Docker metrics via node_exporter: `http://[SWARM_NODE]:9100/metrics`
- Prometheus query API: `http://24.204.72.65:9090/api/v1/query`
- Prometheus query_range API: `http://24.204.72.65:9090/api/v1/query_range` (time-series)
- Prometheus graph: `http://24.204.72.65:9090/graph` (manual metric browsing)

**Environment Variables/Config:**
- Service labels for Prometheus discovery: `prometheus_scrape=true`, `environment=prod|dev`
- Docker logging driver: Configured to send logs to Prometheus (coordinated with Docker Agent)
- Log retention: 3 months or 3GB per container (enforced by logging driver per Docker Agent specs)
- Container metric labels: `container_label_*` for all custom Docker labels
- Logging validation: Verify Docker logging driver format matches Prometheus expectations before scraping

**Example Tasks:**
- Query CPU usage for all production containers (aggregated)
- Compare memory usage of containers across all swarm nodes
- Identify container using most disk I/O
- Track service replica health: Check if all expected replicas are running
- Monitor container network traffic during CI/CD deployment
- Query container logs for errors: Filter by service and severity

**Constraints:**
- Do NOT modify container metrics (read-only)
- Metric queries must be time-bounded (e.g., last 1 hour, last 7 days) to prevent memory exhaustion
- Container logs in Prometheus are limited by retention policy (3 months/3GB); use archive for long-term
- Do NOT query individual container metrics for large deployments (use aggregation functions)
- Network metric queries must account for metric reset on node restart

---

### 4. Network Infrastructure Metrics Skill

**Responsibilities:**
- Monitor WireGuard VPN health and peer connectivity
- Track VPN metrics (handshakes, bytes, peer status)
- Monitor network interface statistics (firewall, routing)
- Diagnose VPN connection issues from metrics
- Alert on VPN health degradation

**Capabilities:**
- Query WireGuard handshake status: `wg show wg0 latest-handshakes` (per peer)
- Query WireGuard peer bytes: `wg show wg0 transfer` (bytes sent/received per peer)
- Query WireGuard peer allowed IPs: `wg show wg0 allowed-ips`
- Query WireGuard endpoint: `wg show wg0 endpoints` (current peer endpoints)
- Calculate handshake age: `(current_time - last_handshake) / 60` (minutes since handshake)
- Query interface status: `wg show wg0` (interface up/down status)
- Query Mullvad VPN status: `wg show wg-mullvad` (if applicable)
- Monitor DNS resolution: Query Pi-hole metrics via `http://24.204.72.65/admin/api.php`
- Check gateway reachability: ICMP ping to 24.204.72.65 (via monitoring)
- Query network I/O per node: `node_network_receive_bytes_total`, `node_network_transmit_bytes_total`

**Key Interfaces/Endpoints:**
- WireGuard interface: `wg0` (local mesh VPN)
- WireGuard Mullvad chain: `wg-mullvad` (external privacy VPN)
- WireGuard command: `sudo wg show [INTERFACE]` (requires SSH access to gateway)
- Pi-hole API: `http://24.204.72.65/admin/api.php?query` (DNS metrics)
- Gateway node: SSH access to 24.204.72.65 for VPN monitoring
- node_exporter: `http://[SWARM_NODE]:9100/metrics` (network interface stats)

**Environment Variables/Config:**
- WireGuard interface names: `wg0` (local), `wg-mullvad` (Mullvad chain)
- Handshake health threshold: <3 minutes = healthy; >3 minutes = alert
- VPN peer status: Query `latest-handshakes` and `transfer` per peer
- Pi-hole DNS queries: Monitor query count and blocked domain percentage
- Network interface monitoring: MTU 1500, track packet loss and errors

**Example Tasks:**
- Monitor WireGuard peer handshake age (alert if >3 minutes)
- Track VPN bytes sent/received per peer over time (capacity planning)
- Verify all expected WireGuard peers are connected
- Query DNS resolution success rate from Pi-hole
- Monitor network interface packet loss and errors on swarm nodes
- Identify high-latency VPN peers (from handshake timing)

**Constraints:**
- WireGuard queries require SSH access to gateway node (24.204.72.65)
- Coordinate with Network Agent for WireGuard configuration changes
- Handshake stale alert threshold: >180 seconds (3 minutes)
- Do NOT attempt to modify WireGuard configuration (read-only monitoring)
- Pi-hole API queries limited to read-only operations
- VPN metrics are only available when interfaces are up

**WireGuard Exporter Script Coordination:**
- Validate exporter script ownership and permissions: must be executable by prometheus user per WireGuard Agent specifications
- Verify exporter output format matches expected metric structure (peer_name labels must align with WireGuard Agent peer configuration)
- Coordinate script updates with WireGuard Agent (notify when exporter metrics change, validate backward compatibility)
- Monitor exporter process health via process count alert: `count(process_exporter{name="wireguard-exporter"}) > 0`

---

### 5. Data Integrity & Backup/Restore Skill

**Responsibilities:**
- Export metrics for long-term backup
- Export alert rules and Prometheus configuration
- Restore metrics and alert rules from backups
- Validate Prometheus data integrity
- Manage backup storage and retention
- Prevent data loss during upgrades

**Capabilities:**
- Export metrics via Prometheus: `curl http://24.204.72.65:9090/api/v1/query_range` (export query results)
- Export snapshot: `curl -X POST http://24.204.72.65:9090/api/v1/admin/tsdb/snapshot` (create instant snapshot)
- Export alert rules: Copy `/etc/prometheus/rules/` directory to backup location
- Export Prometheus config: Copy `/etc/prometheus/prometheus.yml` to backup location
- Backup command: `tar -czf /var/backups/prometheus/metrics_$(date +%Y%m%d).tar.gz /var/lib/prometheus/`
- Restore from backup: `tar -xzf /var/backups/prometheus/metrics_YYYYMMDD.tar.gz -C /var/lib/prometheus/`
- Validate data integrity: `promtool tsdb analyze /var/lib/prometheus/` (check for corruption)
- List backups: `ls -lh /var/backups/prometheus/`
- Verify backup contents: `tar -tzf /var/backups/prometheus/metrics_*.tar.gz`
- Check Prometheus database size: `du -sh /var/lib/prometheus/` (verify 2GB limit not exceeded)

**Key Interfaces/Endpoints:**
- Prometheus snapshot API: `POST http://24.204.72.65:9090/api/v1/admin/tsdb/snapshot`
- Prometheus tsdb CLI: `promtool tsdb` commands for analysis/repair
- Backup storage: `/var/backups/prometheus/` (or external storage)
- Config files: `/etc/prometheus/prometheus.yml`, `/etc/prometheus/rules/*.yml`
- Storage directory: `/var/lib/prometheus/`

**Environment Variables/Config:**
- Backup retention: Keep last 5 backups (60 days rolling window)
- Backup frequency: Daily automated backups recommended (if agent supports scheduling)
- Backup format: `tar.gz` (compressed for storage efficiency)
- Alert rules backup: YAML text format (version-controllable via git)
- Restore procedure: Stop Prometheus → Restore files → Validate → Restart

**Error Handling:**
- If backup fails: Check disk space on `/var/backups/prometheus/`, verify Prometheus is responding
- If restore fails: Verify backup file integrity (`tar -tzf [FILE]`), check permissions on `/var/lib/prometheus/`
- If data corruption detected: `promtool tsdb repair /var/lib/prometheus/` (attempt auto-repair)
- If metrics missing after restore: Verify restore covered entire time range, check retention policy

**Example Tasks:**
- Export all metrics from last 7 days to backup
- Export alert rules and configuration for version control
- Restore metrics from backup after data loss
- Validate Prometheus data integrity before upgrade
- Create snapshot for testing (without stopping Prometheus)
- Verify backup can be restored (dry-run restore test)

**Constraints:**
- Backups must complete within storage limits (2GB Prometheus storage + backup space)
- Do NOT restore backups from incompatible Prometheus versions
- Data restoration requires stopping Prometheus (confirm before proceeding)
- Alert rules must be validated after restore (`promtool check rules`)
- Backup location must be writable and have sufficient space (minimum 2GB free)
- Old backups >60 days should be purged to prevent storage exhaustion

---

### 6. Alertmanager & Alert History Skill

**Responsibilities:**
- Query alert history and status from Alertmanager
- Manage alert suppression and inhibition rules
- Monitor alert firing duration and resolution
- Diagnose alert configuration issues
- Maintain audit trail of alerts

**Capabilities:**
- List firing alerts: `curl http://24.204.72.65:9093/api/v1/alerts?state=firing`
- List resolved alerts: `curl http://24.204.72.65:9093/api/v1/alerts?state=resolved`
- Query alert status by name: Filter alerts by `alertname` label
- Query alert history: `curl http://24.204.72.65:9093/api/v1/alerts/groups`
- View alert silences: `curl http://24.204.72.65:9093/api/v1/silences` (if implemented)
- Check alert firing duration: Compare `StartsAt` and `EndsAt` timestamps
- Identify flapping alerts: Query same alert firing multiple times in short duration
- Check Alertmanager status: `http://24.204.72.65:9093/` (web UI)
- Monitor alert backlog: Count `alerts.count` metric over time

**Key Interfaces/Endpoints:**
- Alertmanager API: `http://24.204.72.65:9093/api/v1/alerts`
- Alertmanager groups: `http://24.204.72.65:9093/api/v1/alerts/groups`
- Alertmanager web UI: `http://24.204.72.65:9093/` (view firing alerts, history)
- Alertmanager config: `/etc/alertmanager/alertmanager.yml` (alert routing, grouping)

**Environment Variables/Config:**
- Alert storage: In-memory history (no external backend configured)
- Alert grouping: By `alertname` and labels (prevents duplicate notifications)
- Alert resolution timeout: Alerts auto-resolve after 5 minutes of non-firing
- Alert history retention: Kept in Alertmanager until restart (volatile)

**Example Tasks:**
- Query all currently firing alerts across the infrastructure
- Identify alert firing for >1 hour (may need threshold adjustment)
- Find alerts resolved in last 24 hours
- Diagnose alert not firing when expected (check Prometheus rule, check if metric exists)
- Monitor CPU alert count: Trend over time to detect chronic issues
- Identify most frequently-fired alerts (tuning candidates)

**Constraints:**
- Alertmanager queries are read-only (no modifications to alerts)
- Alert history is volatile (lost on Alertmanager restart)
- Do NOT modify Alertmanager configuration without approval
- Alert status queries may return stale data (query Prometheus directly for real-time state)
- Alert resolution is automatic (cannot manually resolve in current setup)

---

## Diagnostic Workflows

### Scrape Target Failure Troubleshooting
1. **Symptom**: Metrics missing for a target (shows `up=0` in Prometheus)
2. **Steps**:
   - Check target status: `curl http://24.204.72.65:9090/api/v1/targets` (filter by job name)
   - If target shows "Down", check error message: "connection refused", "timeout", "DNS error", etc.
   - Test network connectivity: `ping [TARGET_IP]` from gateway
   - Test service connectivity: `curl http://[TARGET_IP]:9100/metrics` (verify endpoint responds)
   - Check firewall rules: Coordinate with Network Agent if needed
   - Verify target is running (if container): `docker ps | grep [SERVICE_NAME]`
   - Check target configuration: Verify `prometheus.yml` has correct IP/port/job name
   - If authentication required: Verify credentials/bearer tokens in scrape config
   - Reload configuration: `curl -X POST http://24.204.72.65:9090/-/reload`
   - Recommend: Fix connectivity, update target config, or decommission target

### Alert Rule Not Firing Troubleshooting
1. **Symptom**: Alert should fire but isn't appearing in Alertmanager
2. **Steps**:
   - Verify alert rule exists: `curl http://24.204.72.65:9090/api/v1/rules | grep -i [ALERT_NAME]`
   - Check rule syntax: `promtool check rules /etc/prometheus/rules/` (must pass validation)
   - Verify metric exists: `curl http://24.204.72.65:9090/api/v1/query?query=[METRIC]` (return no results = metric missing)
   - Test alert expression manually: Copy rule expression to Prometheus graph, evaluate over time
   - Check alert duration (`for` field): May be pending if not met for required duration
   - Verify Alertmanager is running: `http://24.204.72.65:9093/` (check web UI loads)
   - Check Prometheus alert status: `curl http://24.204.72.65:9090/api/v1/alerts` (see if "Pending")
   - If pending: Alert condition met but `for` duration not reached yet (wait)
   - Recommend: Fix metric collection, adjust alert expression, or increase `for` duration

### Storage Capacity Approaching Limit Troubleshooting
1. **Symptom**: Prometheus storage approaching 2GB limit; metrics may be purged early
2. **Steps**:
   - Check current storage usage: `du -sh /var/lib/prometheus/`
   - Query disk space available: `df -h /var/lib/prometheus/`
   - If >90% full: Metrics approaching retention purge threshold
   - Identify high-cardinality metrics: Query `prometheus_tsdb_symbol_table_size_bytes` per metric
   - Reduce scrape targets if possible: Remove non-critical targets to reduce metric volume
   - Reduce metric detail: Adjust labels or sampling rate on high-volume targets
   - Backup and archive old metrics: Export to external storage for long-term retention
   - Check retention policy: Verify 30-day retention is correct (`--storage.tsdb.retention.time=30d`)
   - Monitor storage trend: Query `prometheus_tsdb_blocks_bytes` over time
   - Recommend: Export metrics for backup, consider reducing metric volume, or increase storage

### Data Corruption or Integrity Issue Troubleshooting
1. **Symptom**: Prometheus crashes on startup, queries return errors, or metrics appear corrupt
2. **Steps**:
   - Check Prometheus logs: Look for WAL corruption, index errors, or chunk issues
   - Validate database: `promtool tsdb analyze /var/lib/prometheus/` (inspect for corruption)
   - Attempt auto-repair: `promtool tsdb repair /var/lib/prometheus/` (attempts to fix corruption)
   - If repair fails: Restore from latest clean backup: `tar -xzf /var/backups/prometheus/metrics_YYYYMMDD.tar.gz`
   - Verify restored data: `du -sh /var/lib/prometheus/`, check metrics are queryable
   - Restart Prometheus: `systemctl restart prometheus`
   - Check alert rules load: `curl http://24.204.72.65:9090/api/v1/rules` (verify rules are loaded)
   - Monitor for re-corruption: Watch error logs for recurrence
   - Recommend: Root-cause disk/memory issue, backup frequently, upgrade Prometheus if known bugs

### WireGuard Handshake Stale Alert Troubleshooting
1. **Symptom**: Alert fires "WireGuard handshake stale >3 minutes"
2. **Steps**:
   - SSH to gateway (24.204.72.65): Access WireGuard interface directly
   - Check WireGuard status: `sudo wg show wg0` (view all peers and handshake times)
   - Identify stale peer: Look for `latest-handshake` timestamp >180 seconds old
   - Check peer connectivity: `ping [PEER_IP]` (verify network path exists)
   - Check firewall rules: Ask Network Agent to verify UDP port 51820 is open
   - Attempt manual reconnection: `sudo wg-quick down wg0 && sleep 2 && sudo wg-quick up wg0`
   - Verify handshake refreshed: `sudo wg show wg0 | grep latest-handshakes`
   - If handshake still stale: Network issue, peer misconfiguration, or peer offline
   - Recommend: Investigate peer status, check network path, or decommission peer

---

## Writing Best Practices

### Language & Tone
- **Be specific**: Use actual metric names, API endpoints, file paths (e.g., `container_cpu_usage_seconds_total`)
- **Be concise**: Avoid lengthy explanations; use bullet points and examples
- **Be actionable**: Each capability should guide concrete Prometheus operations
- **Avoid ambiguity**: Clearly distinguish read-only queries from configuration changes

### Structure Rules
1. **Headers**: Use descriptive H2-H4 headers (avoid H1 except title)
2. **Lists**: Use bullets for capabilities/constraints; numbers for diagnostic steps
3. **Code**: Wrap commands and paths in backticks (e.g., `` `curl http://24.204.72.65:9090/` ``, `` `/var/lib/prometheus/` ``)
4. **Bold**: Use bold only for section labels and key terms (e.g., `**Responsibilities:**`, `**Prometheus instance**`)
5. **Terminology**: Define technical terms (metrics, cardinality, scrape, reload) in Architecture Context

### Anti-Patterns to Avoid
- ❌ Vague metric names (use exact Prometheus metric names)
- ❌ Missing API endpoint details (always show full curl command examples)
- ❌ Incomplete alert examples (show full rule format with all required fields)
- ❌ No mention of data validation (always validate before deployment)
- ❌ Unclear approval workflows (explicitly state "REQUIRE EXPLICIT APPROVAL" for risky operations)
- ❌ No rollback paths (always provide rollback procedure for destructive operations)

### Best Practices
- ✓ Always validate alert rule syntax before deployment
- ✓ Test new scrape targets on non-production before adding to prod
- ✓ Query metrics for specific time ranges (prevent memory exhaustion from large queries)
- ✓ Backup metrics and alert rules regularly (daily minimum)
- ✓ Coordinate backup schedules with WireGuard Agent for peer configs and WireGuard metrics consistency
- ✓ Keep alert rules organized by service (separate files: `docker_alerts.yml`, `network_alerts.yml`)
- ✓ Use meaningful alert names and descriptions (facilitate troubleshooting)
- ✓ Monitor Prometheus itself (`prometheus_tsdb_blocks_bytes`, disk usage, scrape success rate)
- ✓ Test backup/restore procedures regularly (verify they work before you need them)

---

## Validation Checklist

Before deploying Prometheus changes, verify:

- [ ] All scrape targets respond with HTTP 200 and valid metrics
- [ ] Scrape interval is 15 seconds across all targets
- [ ] Scrape timeout is <10 seconds (less than interval)
- [ ] All alert rules pass syntax validation (`promtool check rules`)
- [ ] Alert rule `for` duration is >=1 minute (prevent flapping)
- [ ] Alert labels include `severity` and `alertname`
- [ ] Alert annotations include `description` (explain what alert means)
- [ ] Prometheus storage usage is <90% of 2GB limit
- [ ] Storage retention is 30 days (not modified)
- [ ] Alertmanager is running and reachable
- [ ] Alert rules are reloaded after any changes
- [ ] Recent backups exist and can be restored
- [ ] Web UI is accessible on internal network (24.204.72.64/26)
- [ ] All scrape targets are on internal network or VPN-accessible

---

## Reference Implementation

**Live Examples:**
- `DOCKER_AGENT_SKILLS.md` - Container metrics and Docker Swarm integration
- `NETWORK_AGENT_SKILLS.md` - Network infrastructure and WireGuard integration
- `WIREGUARD_AGENT_SKILLS.md` - WireGuard exporter script coordination, peer metrics
- `SAMBA_AGENT_SKILLS.md` - Samba metrics exporter, SMB connection monitoring, share capacity alerts
- Prometheus configuration templates and example alert rules (refer to project documentation)

**When implementing a new alert rule:**
1. Define metric to monitor (query manually in Prometheus graph first)
2. Create rule in appropriate file (`/etc/prometheus/rules/[SERVICE]_alerts.yml`)
3. Validate syntax: `promtool check rules /etc/prometheus/rules/`
4. Test rule expression in Prometheus graph over time period
5. Deploy to Prometheus and monitor firing behavior
6. Tune threshold/duration if false positives or false negatives
7. Document alert in this skills file

**When adding a new scrape target:**
1. Test target connectivity from Prometheus (ping, curl metrics endpoint)
2. Add to `prometheus.yml` scrape configuration
3. Verify metric name conventions match existing targets
4. Reload Prometheus: `curl -X POST http://24.204.72.65:9090/-/reload`
5. Query target status: `curl http://24.204.72.65:9090/api/v1/targets`
6. Verify metrics appear in Prometheus within 30 seconds (2 scrapes)
7. Create corresponding alert rule if monitoring for anomalies

---

## Questions to Guide Prometheus Operations

When managing Prometheus, ask:

1. **Which targets need monitoring?** (Docker Swarm, network, external services)
2. **What metric should I query?** (Use Prometheus graph to explore available metrics)
3. **Is this query time-bounded?** (Always include time range to prevent memory exhaustion)
4. **Does this metric exist on all targets?** (Check if metric available before creating alert)
5. **What threshold triggers an alert?** (Define clear threshold; test before deployment)
6. **How long before alert fires?** (Set `for` duration to prevent flapping)
7. **When was the last backup taken?** (Verify regular backups; test restore periodically)
8. **Is storage approaching limit?** (Monitor 2GB limit; archive old metrics if needed)

Answer these for each operation, and you'll maintain reliable Prometheus monitoring.

---

**Last Updated**: September 15, 2026
**Version**: 1.0
**Storage Limit**: 2GB
**Retention**: 30 days
**Scrape Interval**: 15 seconds
**Access**: Internal network (24.204.72.64/26) only
