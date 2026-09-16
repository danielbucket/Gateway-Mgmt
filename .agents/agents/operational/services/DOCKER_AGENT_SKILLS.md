# Docker Swarm Agent Skills

## Overview
This document defines the capabilities and responsibilities of the Docker Swarm Agent for the gateway-mgmt infrastructure. The agent manages a three-node Docker Swarm cluster (1 manager, 2 workers) across on-premise Linux machines, handling container orchestration, service deployment, development/production workloads, CI/CD pipeline execution, and secure jumpbox access. The agent coordinates with the Network Management Agent for firewall rules, routing, and DNS integration.

---

## Docker Swarm Architecture Context

### Core Infrastructure
- **Swarm Cluster**: 1 manager node + 2 worker nodes (3 total Linux machines)
- **Network Topology**: 24.204.72.64/26 (coordinated with Network Infrastructure Agent)
- **Container Communication**: Bridge networks per service (not overlay)
- **External Access Ports**: 8000-9999 range (development), 5000-5999 range (production)
- **Storage**: Local volumes on worker nodes; no shared storage backend currently
- **Docker Version**: Current stable release (latest Docker CE)

### Key Services & Integration Points
- **Prometheus**: Metrics collection and container log aggregation (gateway at 24.204.72.65)
- **Pi-hole DNS**: Container hostname resolution via Pi-hole at 24.204.72.65
- **WireGuard VPN**: VPN access for remote container management and jumpbox tunneling
- **OpenSSH**: SSH key-based authentication for agent operations on swarm nodes
- **node_exporter**: System-level metrics on each swarm node

### Swarm Node Details
- **Manager Node**: Primary orchestration point; manages cluster state and scheduling
- **Worker Node 1**: Executes services; supports production and development containers
- **Worker Node 2**: Executes services; supports production and development containers
- **SSH Access**: SSH keys required; password auth disabled on all nodes
- **Node Discovery**: Swarm uses internal gossip protocol; manager node is primary contact point

### Environment & Credential Management
- **Secrets Storage**: Environment files (`.env`) per service, stored securely on manager node
- **Credential Rotation**: Agent can update `.env` files and restart affected services
- **Path Convention**: Service credentials at `/etc/swarm/services/{service-name}/.env`
- **Permissions**: `600` (user read-write only) on all credential files

### Jumpbox Container
- **Purpose**: Authenticated gateway for tunneling traffic to internal containers and services
- **Authentication**: SSH key-based (matches node SSH keys)
- **Available Tools**: docker CLI, ssh, curl, jq for service access
- **Port**: 2222 (SSH tunnel entry point, external-facing)
- **Network**: Bridge network isolated from application containers
- **Traffic Routing**: SSH tunnels to internal container services via jumpbox

### Container Logging & Monitoring
- **Log Aggregation**: Container stdout/stderr sent to Prometheus via Docker logging driver
- **Retention Policy**: 3 months OR 3GB maximum per container (whichever comes first)
- **Log Queries**: Prometheus API queries for container logs by service name or container ID
- **Metrics Scraped**: CPU, memory, disk I/O, network I/O per container via Prometheus node_exporter

---

## Skill Areas

### 1. Swarm Cluster Setup & Initialization Skill

**Responsibilities:**
- Initialize Docker Swarm cluster on new machines
- Configure manager and worker nodes with proper connectivity
- Ensure all nodes can communicate via swarm gossip protocol
- Validate swarm health after initialization
- Document node roles and join tokens for future scaling

**Capabilities:**
- Initialize swarm on manager node: `docker swarm init --advertise-addr [MANAGER_IP]`
- Generate and retrieve worker join tokens: `docker swarm join-token worker`
- Join worker nodes to swarm: `docker swarm join --token [TOKEN] [MANAGER_IP]:2377`
- Verify node status: `docker node ls`, `docker node inspect [NODE_ID]`
- Check swarm cluster health: `docker info | grep -A 20 "Swarm"`
- Test inter-node communication with ping/traceroute
- Coordinate with Network Agent for firewall rules (port 2377/tcp, 7946/tcp+udp, 4789/udp)

**Example Tasks:**
- Initialize swarm on manager node with correct advertise address
- Add two worker nodes to swarm cluster
- Verify all three nodes report "Ready" and "Active" status
- Test swarm network connectivity by deploying test service across nodes
- Document join tokens and provide to ops team for future node additions

**Constraints:**
- Only initialize swarm on a node that is NOT already in a swarm
- Require explicit confirmation before leaving/removing nodes from cluster
- Do NOT attempt to initialize multiple swarms on the same network
- Verify network connectivity (ping manager from workers) before joining nodes
- Check disk space (minimum 5GB free) on all nodes before initialization

---

### 2. Service Deployment & Container Orchestration Skill

**Responsibilities:**
- Deploy and manage services across the swarm cluster
- Distinguish between development and production service deployments
- Manage service replicas, placement constraints, and resource limits
- Handle rolling updates with zero downtime
- Coordinate external port allocation (dev: 8000-9999, prod: 5000-5999)

**Capabilities:**
- Create services: `docker service create --name [NAME] --image [IMAGE]`
- Deploy services with constraints: `--constraint node.role==manager|worker`
- Set resource limits: `--limit-cpu [VALUE] --limit-memory [VALUE]`
- Allocate external ports: `--publish [PORT]:[CONTAINER_PORT]`
- Update running services: `docker service update --image [NEW_IMAGE] [SERVICE_NAME]`
- Scale services: `docker service scale [SERVICE_NAME]=[REPLICAS]`
- Query service status: `docker service ls`, `docker service ps [SERVICE_NAME]`
- Inspect service details: `docker service inspect [SERVICE_NAME]`
- View service logs: `docker service logs [SERVICE_NAME]` (aggregated across replicas)

**Key Interfaces/Endpoints:**
- Docker Swarm Manager API (manager node port 2375/tcp for local access)
- Service environment via `docker service inspect` and `--env-file` flag
- Prometheus metrics API for service resource tracking

**Environment Variables/Config:**
- Service configs stored in `/etc/swarm/services/{service-name}/.env`
- Environment variables injected at service creation: `--env-file /etc/swarm/services/{name}/.env`
- Development services tagged with label: `environment=dev`
- Production services tagged with label: `environment=prod`

**Example Tasks:**
- Deploy development web service on worker nodes with 512MB memory limit
- Deploy production API service (replicas=3) on workers with persistent storage mount
- Update production service to new image without downtime (rolling update)
- Scale development database to 2 replicas during testing
- View aggregate logs for multi-replica service across all nodes

**Constraints:**
- Development services: Use port range 8000-9999; limit replicas to 1-2; schedule on any worker
- Production services: Use port range 5000-5999; maintain minimum 2 replicas; tolerate 1 node failure
- Require explicit confirmation before removing production services (ask: "Are you sure? This cannot be undone")
- Require explicit confirmation before scaling production services >50% or <50%
- Do NOT remove a service without first draining connections (zero-downtime drain takes ~30s)
- All deployments must include resource limits (CPU and memory)
- Environment files must be validated (checked for syntax errors) before service creation

---

### 3. Jumpbox Container Access & Traffic Tunneling Skill

**Responsibilities:**
- Deploy and manage jumpbox container for secure authenticated access
- Establish SSH tunnels from remote clients through jumpbox to internal services
- Manage jumpbox SSH keys and credential rotation
- Audit and log all jumpbox connections and tunnels
- Monitor jumpbox container health and resource usage

**Capabilities:**
- Deploy jumpbox service: `docker service create --name jumpbox --publish 2222:22 [IMAGE]`
- Verify jumpbox SSH accessibility: `ssh -i [KEY] -p 2222 jump@jumpbox`
- Create SSH tunnels through jumpbox to internal services: `ssh -L [LOCAL_PORT]:internal-service:8080 jump@jumpbox`
- List active SSH connections on jumpbox: `docker exec [JUMPBOX_CONTAINER] who` or `netstat -tnp | grep sshd`
- Retrieve jumpbox container ID: `docker ps -f "name=jumpbox" -q`
- Rotate jumpbox SSH keys: Update `.env` file at `/etc/swarm/services/jumpbox/.env`, restart service
- Monitor jumpbox resource usage via Prometheus metrics
- Check jumpbox container logs: `docker service logs jumpbox`

**Key Interfaces/Endpoints:**
- Jumpbox SSH port: 2222 (external-facing)
- Internal service access via jumpbox SSH tunnels
- Docker service inspect for jumpbox configuration and networking

**Environment Variables/Config:**
- Jumpbox SSH authorized keys: Stored in `/etc/swarm/services/jumpbox/.env`
- Jumpbox credentials rotated by updating `.env` and running: `docker service update --force jumpbox`
- Authorized keys format: One public key per line in `SSH_AUTHORIZED_KEYS` variable

**Error Handling:**
- If jumpbox is unreachable: Check swarm node status (`docker node ls`), verify container is running (`docker ps`), check firewall rules with Network Agent
- If SSH tunnels fail: Verify internal service is running, check bridge network connectivity between jumpbox and service
- If credential rotation fails: Verify `.env` file syntax, check service restart logs

**Example Tasks:**
- Deploy jumpbox container with SSH key authentication
- Establish tunnel from local machine through jumpbox to internal database (port 3306)
- Audit active SSH connections on jumpbox
- Rotate jumpbox SSH keys without disrupting existing connections
- Verify jumpbox connectivity from gateway (24.204.72.65) and from external VPN client

**Constraints:**
- Jumpbox runs on dedicated bridge network (not shared with application services)
- Only SSH-based access allowed; no password authentication
- SSH keys must be 4096-bit RSA or Ed25519; anything weaker requires upgrade
- All jumpbox connections must be logged and retained for 90 days minimum
- Jumpbox resource limits: Max 1 CPU, 512MB memory
- Do NOT expose other ports on jumpbox (SSH only)
- Verify jumpbox can reach WireGuard peers per WireGuard Agent peer configuration before granting access
- Coordinate SSH key management with WireGuard Agent for jumpbox-to-peer authentication
- Confirm network routes to peer nodes (via WireGuard tunnel) are valid for tunnel traffic

---

### 4. Container & Service Monitoring Skill

**Responsibilities:**
- Monitor container and service health across the swarm
- Query Prometheus for container metrics and logs
- Diagnose container failures and performance issues
- Track resource usage and capacity planning
- Alert on anomalies in container behavior

**Capabilities:**
- Query container status: `docker ps`, `docker ps -a` (all containers)
- Inspect container details: `docker inspect [CONTAINER_ID]`
- Retrieve container resource stats: `docker stats [CONTAINER_NAME]` (real-time CPU, memory, I/O)
- Query Prometheus API for historical metrics: container_cpu_usage, container_memory_usage, etc.
- Retrieve container logs: `docker service logs [SERVICE_NAME]` or direct container logs
- Check container exit codes and failure reasons: `docker inspect [CONTAINER_ID] | grep -A 5 "ExitCode"`
- Query Prometheus for log aggregation: Recent logs for service via `container_stdout_*` metrics
- Identify resource-constrained containers: Compare usage vs limits via Prometheus
- Monitor service replica health: `docker service ps [SERVICE_NAME]` (shows running, failed, desired replicas)

**Key Interfaces/Endpoints:**
- Prometheus API: `http://24.204.72.65:9090/api/v1/query` (query current metrics)
- Prometheus API: `http://24.204.72.65:9090/api/v1/query_range` (query metrics over time period)
- Docker stats API: Real-time container resource usage
- Swarm logs aggregation via Prometheus

**Environment Variables/Config:**
- Prometheus scrape configuration includes Docker Swarm metrics targets
- Log retention via Prometheus: 3 months OR 3GB per container (enforced by Docker logging driver)
- Container labels for Prometheus scraping: `prometheus_scrape=true`, `service_name=[NAME]`

**Error Handling:**
- If container is stuck (not starting): Check container logs for errors, verify image exists, check resource limits
- If service metrics missing from Prometheus: Verify node_exporter is running on node, check Prometheus scrape logs
- If logs are truncated: Verify 3GB/3-month retention limit not exceeded, rotate old logs if needed

**Example Tasks:**
- Check real-time CPU/memory usage of production API service across all replicas
- Retrieve last 100 lines of logs for failing service
- Query Prometheus for CPU usage trend over past week for database container
- Identify which container crashed and why (exit code, last log lines)
- Alert if any container exceeds 80% of memory limit

**Constraints:**
- Do NOT force-stop monitoring containers (Prometheus, node_exporter, logging infrastructure)
- Log queries are read-only; cannot modify or delete logs
- Retention limits (3 months/3GB) are enforced automatically; do NOT bypass
- Do NOT query metrics for containers not belonging to current service scope

---

### 5. Credential Rotation & Secret Management Skill

**Responsibilities:**
- Rotate service credentials (database passwords, API keys, etc.)
- Update environment files on the manager node
- Restart affected services with new credentials
- Validate credential changes take effect
- Maintain audit trail of rotation events

**Capabilities:**
- Update service `.env` file: `vi /etc/swarm/services/{service-name}/.env`
- Validate `.env` syntax: Check for valid KEY=VALUE format, no special characters in keys
- Restart service with new credentials: `docker service update --force [SERVICE_NAME]`
- Retrieve current service credentials: `docker service inspect [SERVICE_NAME] | grep -A 20 "Env"`
- Verify credential change took effect: Query Prometheus for service restart timestamp, check logs for "new credential loaded"
- Audit credential rotation history: Check file modification time on `.env`, view service update logs

**Key Interfaces/Endpoints:**
- Environment file storage: `/etc/swarm/services/{service-name}/.env`
- Service environment variables accessible via: `docker service inspect [SERVICE_NAME]`

**Environment Variables/Config:**
- Credentials stored as plain-text in `.env` files; protected by filesystem permissions (600)
- File ownership: Only swarm user can read/write
- Backup: Maintain offline backups of sensitive `.env` files
- Rotation frequency: Every 90 days minimum (security best practice)

**Error Handling:**
- If `.env` syntax is invalid: Service fails to start; fix syntax, restart service
- If new credentials don't work: Rollback `.env` to previous version, verify credential format
- If service doesn't restart: Check Docker service update logs for errors, manually verify new `.env` file

**Example Tasks:**
- Rotate database password in production database service `.env`
- Update API key for external service integration
- Verify production service restarted with new credentials (check Prometheus timestamp, query service health)
- Audit all credential rotations in past 90 days
- Rollback to previous credentials if new ones fail

**Constraints:**
- Require explicit confirmation before rotating production service credentials
- All credential files must have permissions 600 (owner read-write only)
- Credentials must be validated (format check) before restarting service
- Keep offline backup of previous credentials (for rollback) for 30 days
- Do NOT store credentials in Docker images (use environment files only)
- Do NOT log credentials to stdout/stderr (escape sensitive values in logs)

---

### 6. Service Networking & Bridge Management Skill

**Responsibilities:**
- Create and manage bridge networks for service communication
- Isolate development and production services on separate networks
- Configure DNS resolution within bridge networks
- Diagnose and resolve network connectivity issues between containers
- Coordinate external access patterns via gateway ports

**Capabilities:**
- Create bridge network: `docker network create --driver bridge [NETWORK_NAME]`
- List networks: `docker network ls`
- Inspect network details: `docker network inspect [NETWORK_NAME]`
- Connect/disconnect services to networks: `docker network connect|disconnect [NETWORK_NAME] [CONTAINER_NAME]`
- Verify DNS resolution between containers: `docker exec [CONTAINER] nslookup [CONTAINER_NAME]`
- Test network connectivity: `docker exec [CONTAINER] ping [OTHER_CONTAINER]`
- Check network routing and bridge configuration: `docker network inspect [NETWORK_NAME] | grep -A 10 "Containers"`
- Allocate external ports on specified port ranges: Dev 8000-9999, Prod 5000-5999

**Key Interfaces/Endpoints:**
- Bridge networks: Isolated L2 networks per service or service group
- DNS via embedded server in swarm (Docker DNS 127.0.0.11:53)
- Pi-hole DNS (24.204.72.65) for host-level DNS queries

**Environment Variables/Config:**
- Network naming convention: `{service-name}-net` or `dev-net`, `prod-net`
- IPAM configuration: Use default swarm IPAM (no manual IP assignment)
- MTU: 1500 bytes (standard Ethernet)

**Example Tasks:**
- Create separate bridge networks for dev and prod environments
- Connect web service to application network, verify DNS resolution
- Diagnose "cannot reach database from web container" (check network, DNS, firewall)
- Change external port for service without disrupting traffic (update port mapping)
- Verify production and development containers cannot communicate cross-network

**Constraints:**
- Each service group should use separate bridge network (dev/prod isolation)
- Do NOT use host network mode for application containers
- Do NOT assign static IPs to containers (use DNS discovery)
- External ports: Dev 8000-9999, Prod 5000-5999 (coordinated with firewall rules)
- Pi-hole DNS must be configured as upstream resolver for bridge networks
- Coordinate network/port changes with Network Agent for firewall rule updates

---

## Diagnostic Workflows

### Service Deployment Failure Troubleshooting
1. **Symptom**: Service deployment fails or containers crash immediately after deployment
2. **Steps**:
   - Check service status: `docker service ps [SERVICE_NAME]` (look for failed replicas, error messages)
   - If "Desired" != "Running", check container logs: `docker service logs [SERVICE_NAME]`
   - If image pull fails: Verify image exists, check registry connectivity (not needed currently)
   - If container exits: Check exit code and logs for clues (memory OOM, missing file, bad config)
   - If resource limits: Increase `--limit-memory` or `--limit-cpu` and retry deployment
   - Verify `.env` file exists and is readable if environment file is used: `ls -la /etc/swarm/services/[NAME]/.env`
   - If network issue: Verify bridge network exists and service is connected
   - Recommend: Update image, adjust resource limits, fix config, or adjust placement constraints

### Jumpbox SSH Connection Failure Troubleshooting
1. **Symptom**: Cannot SSH into jumpbox container (Connection refused, timeout, or key rejected)
2. **Steps**:
   - Verify jumpbox service is running: `docker service ps jumpbox` (check for "Running" status)
   - If not running: Check service logs for startup errors: `docker service logs jumpbox`
   - If running, verify SSH port is exposed: `docker service inspect jumpbox | grep -A 5 "Ports"`
   - Test SSH connectivity to jumpbox: `ssh -v -i [KEY] -p 2222 jump@jumpbox` (verbose output)
   - If "Connection refused": Jumpbox SSH daemon not listening (check container logs)
   - If "Key rejected": Verify public key in jumpbox `.env` matches your private key
   - If timeout: Check firewall rules with Network Agent; verify 2222/tcp is allowed to jumpbox
   - Recommend: Rotate SSH keys, restart jumpbox service, or verify firewall rules

### Container Resource Exhaustion Troubleshooting
1. **Symptom**: Container running slowly, frequent restarts, or "Out of memory" errors
2. **Steps**:
   - Check current resource usage: `docker stats [SERVICE_NAME]` (compare CPU/memory to limits)
   - Query Prometheus for usage trend: Memory/CPU usage over past hour
   - If memory near limit: `docker service inspect [SERVICE_NAME] | grep -i "memory"`
   - If CPU-bound: Analyze application logs for slow queries or infinite loops
   - If disk full on node: `docker system df` (check image, container, volume storage)
   - Check for stuck/zombie containers: `docker ps -a` (filter by "Exited")
   - If production service: Increase resource limits and redeploy
   - Recommend: Vertical scaling (increase limits), horizontal scaling (add replicas), or optimize application

### Multi-Node Service Failover Troubleshooting
1. **Symptom**: Service replicas not running on all expected nodes, or failover not occurring
2. **Steps**:
   - Check swarm node status: `docker node ls` (verify all nodes "Ready" and "Active")
   - If node is "Down" or "Unavailable": Contact ops team, may need node recovery
   - Check service replica distribution: `docker service ps [SERVICE_NAME]` (see which nodes have replicas)
   - If uneven distribution: May indicate placement constraints or resource issues on a node
   - Query swarm events for failures: `docker events --filter type=container` (look for recent crashes)
   - If container crash loop: Check application logs for root cause
   - Verify node can reach other nodes (swarm gossip): Ask Network Agent to test connectivity
   - Recommend: Fix root cause (resource limits, configuration), heal failed node, or rescale service

### Credential Rotation Failure Troubleshooting
1. **Symptom**: Service fails after credential rotation, or new credentials don't take effect
2. **Steps**:
   - Verify `.env` file was updated correctly: `cat /etc/swarm/services/[NAME]/.env`
   - Check `.env` file syntax: Each line should be KEY=VALUE with no spaces around `=`
   - Verify file permissions: `ls -la /etc/swarm/services/[NAME]/.env` (should be 600)
   - Check if service was restarted: `docker service inspect [SERVICE_NAME] | grep -i "UpdatedAt"`
   - If service didn't restart: Manually restart: `docker service update --force [SERVICE_NAME]`
   - Verify new credentials take effect: Check service logs for "credential loaded" or connection success
   - If credentials still don't work: Test with old credentials to confirm rollback path
   - Recommend: Rollback to previous `.env` (kept in backup), fix credential format, or troubleshoot downstream service

---

## Writing Best Practices

### Language & Tone
- **Be specific**: Use actual Docker commands, container names, port ranges (5000-5999 prod, 8000-9999 dev)
- **Be concise**: Avoid lengthy explanations; use bullet points and examples
- **Be actionable**: Each capability should guide concrete Docker operations
- **Avoid ambiguity**: Clearly distinguish dev vs prod environments, confirm destructive actions

### Structure Rules
1. **Headers**: Use descriptive H2-H4 headers (avoid H1 except title)
2. **Lists**: Use bullets for capabilities/constraints; numbers for diagnostic steps
3. **Code**: Wrap Docker commands in backticks (e.g., `` `docker service ls` ``, `` `/etc/swarm/services/` ``)
4. **Bold**: Use bold only for section labels and key terms (e.g., `**Responsibilities:**`, `**Bridge networks**`)
5. **Terminology**: Define technical terms (Swarm, Manager, Worker, Bridge, Overlay) in Architecture Context

### Anti-Patterns to Avoid
- ❌ Vague constraints ("be careful with production" – specify what requires confirmation)
- ❌ Incomplete examples (show full Docker commands, not just concepts)
- ❌ Missing port ranges or network details (always specify dev vs prod patterns)
- ❌ Credentials in examples or logs (use placeholders like `[PASSWORD]`, `[API_KEY]`)
- ❌ Unclear env file locations (always use `/etc/swarm/services/{name}/.env`)
- ❌ No mention of retry/rollback paths (credential rotation must include rollback)

### Best Practices
- ✓ Always confirm before removing production services
- ✓ Test credential rotation on dev service before production
- ✓ Keep resource limits realistic (monitor actual usage first)
- ✓ Use bridge networks to isolate dev/prod and prevent cross-environment access
- ✓ Verify swarm node health before deploying new services
- ✓ Document port allocations (dev 8000-9999, prod 5000-5999) to prevent conflicts
- ✓ Log all significant operations (credential rotation, service updates) for audit trail
- ✓ Test failover by deliberately stopping a node and verifying service continuity

---

## Validation Checklist

Before executing swarm operations, verify:

- [ ] Swarm cluster initialized and all 3 nodes "Ready" and "Active" status
- [ ] Manager node is accessible and reachable via network
- [ ] All `.env` files have correct syntax (KEY=VALUE format)
- [ ] Service labels (`environment=dev` or `environment=prod`) are set correctly
- [ ] Bridge networks are created and services are connected to appropriate network
- [ ] Resource limits are set for all services (CPU and memory)
- [ ] External ports do not conflict (dev 8000-9999, prod 5000-5999)
- [ ] Jumpbox is running and SSH is accessible on port 2222
- [ ] Prometheus is scraping container metrics and logs successfully
- [ ] Production services have minimum 2 replicas for fault tolerance
- [ ] All sensitive credentials are stored in `.env` files (not in Dockerfile or images)
- [ ] Firewall rules are coordinated with Network Agent for exposed ports

---

## Reference Implementation

**Live Examples:**
- `AUDIT_VALIDATION_AGENT_SKILLS.md` - Pre-deployment validation, structural completeness audits, port coordination verification
- `NETWORK_AGENT_SKILLS.md` - Network context and firewall coordination
- `PROMETHEUS_AGENT_SKILLS.md` - Docker container metrics scraping, logging driver coordination
- `WIREGUARD_AGENT_SKILLS.md` - Jumpbox VPN access coordination, peer authentication flows
- `SAMBA_AGENT_SKILLS.md` - Container-based Samba file sharing, SMB port coordination
- Swarm initialization templates and service manifests (refer to project documentation)

**When implementing a new swarm service:**
1. Start with the Service Deployment & Container Orchestration Skill template
2. Determine if service is dev or prod (affects port range, replicas, constraints)
3. Coordinate with Network Agent for firewall rules and port ranges
4. Verify jumpbox network connectivity with WireGuard Agent if service requires remote access
5. Create appropriate bridge network and set resource limits
6. Create `.env` file at `/etc/swarm/services/{service-name}/.env` with credentials
7. Deploy with proper labels for Prometheus discovery (coordinated with Prometheus Agent)
8. Verify Docker logging driver is configured per Prometheus Agent specifications
9. Test failover by stopping a node and verifying service continuity
10. Use the Validation Checklist before going live

---

## Questions to Guide Swarm Operations

When deploying a new service, ask:

1. **Is this development or production?** (Affects port range: dev 8000-9999 vs prod 5000-5999)
2. **How many replicas should run?** (Dev: 1-2, Prod: minimum 2 for fault tolerance)
3. **What resources does it need?** (Memory/CPU limits to prevent resource exhaustion)
4. **Does it need external access?** (If yes, which ports and from where?)
5. **Does it require credentials?** (If yes, create `.env` file with format validation)
6. **Should it access other services?** (If yes, connect to appropriate bridge network)
7. **How should we monitor it?** (Container health check, logs in Prometheus, resource usage)
8. **What's the rollback plan if deployment fails?** (Know how to revert to previous version)

Answer these for each service, and you'll have a clear, well-scoped deployment plan.

---

**Last Updated**: September 15, 2026
**Version**: 1.0
**Cluster**: 1 Manager + 2 Workers (3 nodes total)
