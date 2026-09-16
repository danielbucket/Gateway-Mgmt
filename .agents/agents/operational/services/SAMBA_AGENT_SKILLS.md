# Samba Agent Skills

## Overview
This document defines the capabilities and responsibilities of the Samba Agent for the gateway-mgmt infrastructure. The agent manages network file sharing across the local mesh network via Samba/SMB protocol, handling share creation and management, user authentication and access control, metrics collection for Prometheus monitoring, troubleshooting SMB connectivity issues, and backup coordination. The agent runs two containerized Samba servers (one on each Docker node at 24.204.72.65 and 24.204.72.66) providing three primary shares (media, backups, miscellanea) accessible only from the internal network (24.204.72.64/26) via WireGuard peers and internal Docker containers. The agent coordinates with Network Agent for firewall rules, Docker Agent for container orchestration, Prometheus Agent for metrics collection and alerting, and WireGuard Agent for secure peer access via jumpbox tunneling.

---

## Samba Infrastructure Context

### Core Infrastructure
- **Samba Servers**: Two Docker containers running `samba:latest` (official image)
  - Container 1: Runs on Docker node at 24.204.72.65 (gateway)
  - Container 2: Runs on Docker node at 24.204.72.66 (SpaceBase)
- **Listening Ports**: 445/tcp (SMB direct), 137-138/udp (NetBIOS name services)
- **Network Access**: Internal only (24.204.72.64/26); accessible via WireGuard peers and internal Docker containers
- **Configuration Location**: `/etc/samba/` (inside containers)
- **Share Storage Locations**: Standard Linux paths within containers
  - `/media` - Media share (1.990TB)
  - `/backups` - TimeMachine backup storage (1TB)
  - `/miscellanea` - Information repository (as large as possible)
- **Samba Version**: 4.19.5-Ubuntu (coordinated with container image)
- **Access Control**: Local Samba user database (no LDAP/AD); `smbpasswd` for user management
- **Authentication**: Required for all connections; no guest access allowed

### Key Services & Integration Points
- **Docker Agent**: Orchestrates Samba container deployment and management (coordinated with Docker Agent)
- **Network Agent**: Manages firewall rules for SMB ports 445/tcp and 137-138/udp (coordinated with Network Agent)
- **Prometheus Agent**: Collects Samba metrics via custom exporter script `/usr/local/bin/samba-exporter.sh` (coordinated with Prometheus Agent)
- **WireGuard Agent**: Samba accessible via WireGuard peers through jumpbox SSH tunneling (coordinated with WireGuard Agent)
- **Pi-hole DNS**: User name resolution and potential central auth coordination (coordinated with Network Agent)

### Share Configuration
- **Media Share**:
  - Path: `/media` (1.990TB)
  - Purpose: Media content storage
  - Access: media_users group, read/write permissions
  - Browseable: Yes

- **Backups Share**:
  - Path: `/backups` (1TB)
  - Purpose: TimeMachine and system backup storage
  - Access: backup_users group, read/write permissions
  - Browseable: Yes

- **Miscellanea Share**:
  - Path: `/miscellanea` (as large as available)
  - Purpose: Information repository with dedicated AI agent coordination
  - Access: media_users and backup_users, read/write permissions
  - Browseable: Yes

### User Management
- **Admin User**: `samba_admin` (Samba server administration)
- **Service Accounts**: For automated Docker container access (credentials stored in encrypted volumes)
- **Regular Users**: Created via `smbpasswd` tool; password rotation on-demand
- **Groups**:
  - `media_users` - Access to media and miscellanea shares
  - `backup_users` - Access to backups and miscellanea shares
  - `all_users` - Read-only access to all shares

### Monitoring & Alerting
- **Metrics Export**: Custom script `/usr/local/bin/samba-exporter.sh` exports Prometheus metrics
- **Scrape Interval**: 15 seconds (synchronized with Prometheus Agent)
- **Metrics**: Active SMB connections, authenticated users per share, share I/O bytes (read/write)
- **Alerts**:
  - Failed authentication attempts (>5 failed logins in 5-minute window)
  - Share capacity approaching limit (>90% full on any share)
  - Samba service down or unresponsive
  - SMB connection limit reached (max 10 concurrent)

### Logging & Audit
- **Log Location**: `/var/log/samba/` (inside containers)
- **Log Retention**: 30 days minimum (coordinated with Prometheus backup policy)
- **Audit Level**: Track failed authentications, share access, user connects/disconnects
- **Backup Coordination**: Future backups will be coordinated with Prometheus Agent and Network Agent

### Remote Access via Jumpbox
- **Access Method**: SSH tunneling through jumpbox container to Samba container
- **Standard Tunneling**: `ssh -L 445:samba-container-ip:445 jump@jumpbox` (local SMB access)
- **Name Services**: `ssh -L 137:samba-container-ip:137 -L 138:samba-container-ip:138 jump@jumpbox` (UDP tunnels)
- **Use Case**: Remote WireGuard peers connect via jumpbox proxy to access shares

---

## Skill Areas

### 1. Samba Container Deployment & Configuration Skill

**Responsibilities:**
- Deploy Samba containers on designated Docker nodes (24.204.72.65 and 24.204.72.66)
- Configure container networking to host network (ports 445/tcp, 137-138/udp accessible)
- Mount persistent volumes for share storage
- Generate and manage `smb.conf` configuration
- Initialize share directories with correct permissions
- Verify container health and service startup

**Capabilities:**
- Deploy Samba container: `docker service create --name samba --image samba:latest --network host [VOLUME_MOUNTS]`
- Retrieve container status: `docker ps | grep samba` or `docker service ps samba`
- Verify SMB port accessibility: `netstat -tlnp | grep 445` or `ss -tlnp | grep 445`
- Check Samba daemon status inside container: `docker exec [CONTAINER] systemctl status smbd`
- View container logs: `docker service logs samba` or `docker logs [CONTAINER_ID]`
- Verify share configuration: `docker exec [CONTAINER] smbclient -L localhost -U% -m SMB3` (test list shares)
- Mount volumes for shares: Create Docker volumes or bind mounts at `/media`, `/backups`, `/miscellanea`
- Generate default `smb.conf`: Template-based configuration with three shares pre-configured
- Set share permissions: `docker exec [CONTAINER] chmod 755 /media /backups /miscellanea`
- Validate configuration: `docker exec [CONTAINER] testparm /etc/samba/smb.conf` (syntax check)

**Key Interfaces/Endpoints:**
- Docker service/container CLI: `docker service create`, `docker ps`, `docker exec`
- Samba config file: `/etc/samba/smb.conf` (accessible inside container)
- Share directories: `/media`, `/backups`, `/miscellanea`
- Samba daemon: `smbd` process (must be running for SMB access)
- Testparm utility: `/usr/bin/testparm` (config validation)
- Container networking: Host network mode (not bridge)

**Environment Variables/Config:**
- Container image: `samba:latest` (official Docker Hub image)
- Samba version: 4.19.5-Ubuntu (from image)
- Network mode: host (ports accessible directly on node)
- Volume mounts: Persistent storage for `/media`, `/backups`, `/miscellanea`
- `smb.conf` settings:
  - `workgroup = WORKGROUP` (default)
  - `server role = standalone server`
  - `disable netbios = yes` (use port 445 only, NetBIOS optional on 137-138)
  - `smb ports = 445 137 138`
  - `guest ok = no` (no anonymous access)
  - `security = user` (user-based authentication)

**Example Tasks:**
- Deploy Samba container on gateway node (24.204.72.65)
- Configure media share with 1.990TB storage
- Verify SMB port 445 is listening on both nodes
- Check share list visible from internal network: `smbclient -L 24.204.72.65 -U%`
- Mount new volume to `/backups` directory
- Validate `smb.conf` syntax before container deployment

**Constraints:**
- Container must use host network (no bridge network; ports must be directly accessible)
- All shares must use host paths (not Docker volumes, for persistence)
- Samba version must remain 4.19.5 or later for SMB3 support
- Configuration changes require container restart: `docker service update --force samba`
- No guest access allowed; authentication required for all connections
- Coordinate firewall rules with Network Agent before deployment
- Coordinate container scheduling with Docker Agent

---

### 2. User Account Management & Authentication Skill

**Responsibilities:**
- Create and manage local Samba user accounts
- Set and rotate user passwords securely
- Manage user group memberships for access control
- Create and maintain service accounts for automation
- Audit user accounts and permissions
- Disable/remove inactive users

**Capabilities:**
- Create user account: `docker exec [CONTAINER] useradd -m [USERNAME]` (system user), then `docker exec [CONTAINER] smbpasswd -a [USERNAME]` (Samba user)
- Set user password: `docker exec [CONTAINER] smbpasswd [USERNAME]` (interactive prompt or piped)
- Create group: `docker exec [CONTAINER] groupadd [GROUPNAME]`
- Add user to group: `docker exec [CONTAINER] usermod -a -G [GROUPNAME] [USERNAME]`
- List users: `docker exec [CONTAINER] pdbedit -L` (Samba user database)
- List groups: `docker exec [CONTAINER] getent group`
- Check user group membership: `docker exec [CONTAINER] id [USERNAME]`
- Disable user: `docker exec [CONTAINER] smbpasswd -d [USERNAME]` (disable SMB login)
- Delete user: `docker exec [CONTAINER] userdel -r [USERNAME]`
- Set password expiration: `docker exec [CONTAINER] pdbedit -P "maximum password age" -u [USERNAME]`
- Verify user in database: `docker exec [CONTAINER] pdbedit -L -u [USERNAME]`
- Check failed login attempts: `docker exec [CONTAINER] grep "Failed" /var/log/samba/log.* | tail -20`

**Key Interfaces/Endpoints:**
- Samba user database: `/var/lib/samba/private/passdb.tdb` (inside container, binary format)
- Command-line tools: `smbpasswd`, `pdbedit`, `useradd`, `usermod`, `groupadd`
- Logging: `/var/log/samba/` (failed auth attempts logged)
- User home directories: `/home/[USERNAME]/` (optional, for file storage)

**Environment Variables/Config:**
- User database backend: `passdb backend = tdbsam` (standard for standalone Samba)
- Password policy: Minimum length 8 characters, complexity optional
- Service accounts: Stored with long random passwords in encrypted Docker volumes
- Groups for access control:
  - `media_users` - Media and miscellanea share access
  - `backup_users` - Backups and miscellanea share access
  - `all_users` - Read-only access to all shares
- Admin account: `samba_admin` with full Samba privileges
- Example regular users: `empire` (coordinated example), plus randomized service accounts

**Example Tasks:**
- Create user "empire" with secure password and add to `media_users` group
- Create service account for Docker container with random 32-char password
- List all Samba users and their group memberships
- Rotate password for service account (30-day policy)
- Disable user account for inactive user (>90 days no login)
- Add existing user to `backup_users` group for backup share access
- Verify failed login attempts for security audit

**Constraints:**
- User creation requires root/container exec privileges
- Passwords must be at least 8 characters
- Service account passwords stored in encrypted volumes (not in config files)
- User deletion is irreversible (archive data before deletion)
- Group names must be unique
- Coordinate user creation with documentation (track who has access to what)
- Users must exist in system (`useradd`) before Samba user creation
- Maximum 10 concurrent SMB connections total (enforced by connection limit)

---

### 3. Share Management & Permissions Skill

**Responsibilities:**
- Create and manage Samba shares (media, backups, miscellanea)
- Set share-level and file-level permissions
- Manage share access control lists (ACLs)
- Monitor share capacity and disk usage
- Configure share properties (browseable, read-only, guest access, etc.)
- Coordinate with backup strategy

**Capabilities:**
- Create share entry in `smb.conf`: Add [share_name] section with Path, Comment, Valid Users, Writable, etc.
- Apply configuration: `docker exec [CONTAINER] testparm` (validate), then restart container
- List configured shares: `docker exec [CONTAINER] net conf list`
- Check share permissions: `docker exec [CONTAINER] ls -ld /media /backups /miscellanea` (directory permissions)
- Set share permissions: `docker exec [CONTAINER] chmod 770 /media` (rwx for owner/group, no other)
- Verify group ownership: `docker exec [CONTAINER] ls -ld /media /backups /miscellanea` (check group column)
- Set share owner: `docker exec [CONTAINER] chown root:media_users /media` (group-based access)
- Test share access: `docker exec [CONTAINER] smbclient //localhost/media -U [USER] -c "ls"`
- Check disk usage: `docker exec [CONTAINER] du -sh /media /backups /miscellanea`
- Set share quota (if enabled): `docker exec [CONTAINER] edquota [USERNAME]` (limit user space per share)
- List ACLs: `docker exec [CONTAINER] getfacl /media` (view access control lists)
- Modify ACLs: `docker exec [CONTAINER] setfacl -m g:media_users:rwx /media` (grant group permissions)
- Configure share browseable: Update `smb.conf` `browseable = yes/no` (if share visible in list)
- Restrict share access: Set `valid users = @media_users` (only group members)

**Key Interfaces/Endpoints:**
- Samba config: `/etc/samba/smb.conf` (per-share [section] definitions)
- Share directories: `/media`, `/backups`, `/miscellanea`
- File system permissions: Standard Linux rwx (owner, group, other)
- Access control: Samba user/group validation
- Quota system: `edquota` (if enabled; optional)
- SMB client: `smbclient //hostname/share -U user` (test access)

**Environment Variables/Config:**
- Media share:
  - Path: `/media` (1.990TB storage)
  - Valid users: `@media_users` group
  - Writable: Yes
  - Browseable: Yes
  - Comment: "Media content storage"

- Backups share:
  - Path: `/backups` (1TB storage)
  - Valid users: `@backup_users` group
  - Writable: Yes
  - Browseable: Yes
  - Comment: "TimeMachine and system backups"

- Miscellanea share:
  - Path: `/miscellanea` (as large as possible)
  - Valid users: `@media_users @backup_users` (both groups)
  - Writable: Yes
  - Browseable: Yes
  - Comment: "Information repository with AI agent coordination"

**Example Tasks:**
- Set media share accessible only to `media_users` group (validate with `smbclient`)
- Check available space on backups share: `du -sh /backups` (verify <1TB used)
- Grant new user access to media share by adding to `media_users` group
- Verify miscellanea share is accessible to both user groups
- Test share access from different user account: `smbclient //24.204.72.65/media -U empire`
- Adjust permissions to restrict write access to backup_users only for backups share

**Constraints:**
- Share paths must exist and be mounted before share activation
- Group ownership enforces share access (coordinated with User Account Management Skill)
- Permissions apply at both SMB level (`smb.conf`) and file system level (Linux ACLs)
- Share names are case-insensitive in SMB but case-sensitive in config
- No guest access on any share (security requirement)
- Share capacity alerts should be coordinated with Prometheus Agent (>90% full)
- Share modifications require `testparm` validation and container restart
- Backup share should be reserved for backup traffic only (coordinate with backup strategy)

---

### 4. Metrics Collection & Prometheus Integration Skill

**Responsibilities:**
- Maintain and execute custom Samba exporter script `/usr/local/bin/samba-exporter.sh`
- Export SMB metrics in Prometheus format
- Monitor active connections, authenticated users, share I/O
- Coordinate metric updates with Prometheus Agent
- Ensure exporter runs within 15-second scrape window
- Validate metric format and backward compatibility

**Capabilities:**
- Execute exporter script: `/usr/local/bin/samba-exporter.sh` (output Prometheus format)
- Query active SMB connections: `docker exec [CONTAINER] smbstatus -b` (brief connection list)
- Query authenticated users: `docker exec [CONTAINER] smbstatus -u` (user connection status)
- Query share I/O stats: Parse `smbstatus` output for bytes read/written per share
- Verify script permissions: `ls -l /usr/local/bin/samba-exporter.sh` (must be executable)
- Check script output format: Run script and verify `# HELP` and `# TYPE` lines present
- Validate metric names: Ensure `samba_*` prefix, share name labels, user labels
- Monitor exporter stderr: Check `/var/log/samba-exporter.log` for errors
- Test exporter execution: Run manually and verify metrics output within 10 seconds
- Coordinate with Prometheus Agent: Notify when exporter output format changes
- Verify backward compatibility: New exporter version must support previous metric names
- Monitor exporter process health: Alert if exporter fails or exceeds timeout

**Key Interfaces/Endpoints:**
- Exporter script: `/usr/local/bin/samba-exporter.sh`
- Script output format: Prometheus text format (metrics with HELP/TYPE documentation)
- Log file: `/var/log/samba-exporter.log` (script execution logs)
- SMB status tool: `smbstatus` (detailed connection/user information)
- Prometheus scrape: Exporter metrics included in `http://24.204.72.65:9090/metrics`
- Container command: `docker exec [CONTAINER] [COMMAND]` (execute queries inside container)

**Environment Variables/Config:**
- Exporter script path: `/usr/local/bin/samba-exporter.sh`
- Execution interval: 15 seconds (synchronized with Prometheus scrape interval)
- Script timeout: 10 seconds maximum (prevent blocking scrape cycle)
- Metric labels: Must include `share` (media, backups, miscellanea), `container_name`, `host`
- Output destination: stdout (captured by Prometheus)
- Script permissions: 755 (executable), owner root:root
- Metrics exported:
  - `samba_connections_total` - Total active SMB connections
  - `samba_authenticated_users` - Authenticated users per share
  - `samba_share_io_bytes_read_total` - Bytes read from share
  - `samba_share_io_bytes_written_total` - Bytes written to share
  - `samba_share_capacity_bytes` - Total share capacity
  - `samba_share_used_bytes` - Currently used space on share
  - `samba_failed_authentication_attempts_total` - Failed login count

**Example Tasks:**
- Execute exporter script and verify Prometheus metric format
- Query active SMB connections: `smbstatus -b` to see who's connected
- Check share I/O statistics: Extract bytes read/written per user per share
- Monitor exporter execution time: Ensure <10 second completion
- Update exporter to include new `samba_service_health` metric
- Test exporter backward compatibility (old Prometheus queries still work)
- Alert if exporter fails or metrics missing from scrape

**Constraints:**
- Exporter output must be valid Prometheus format (fails if invalid)
- Script must complete within 10 seconds (prevent Prometheus scrape backlog)
- Share names in labels must exactly match `smb.conf` share names (case-sensitive)
- Do NOT modify exporter script without Prometheus Agent notification
- Exporter script changes require backward compatibility validation
- Metrics must be consistent across container restarts
- Connection/user counts reset on container restart (coordinate with monitoring)
- Failed auth metric should count within sliding time window (e.g., last 5 minutes)

---

### 5. Troubleshooting & Connectivity Diagnostics Skill

**Responsibilities:**
- Diagnose SMB connection failures from internal network and WireGuard peers
- Troubleshoot authentication issues (failed login, password problems)
- Diagnose share access and permission problems
- Test Samba service health and responsiveness
- Resolve network and firewall-related connectivity issues
- Coordinate with Network Agent for firewall rule verification

**Capabilities:**
- Test SMB connectivity: `smbclient -L 24.204.72.65 -U% -m SMB3` (list shares without auth)
- Test authenticated connection: `smbclient //24.204.72.65/media -U empire -c "ls"`
- Check Samba daemon: `docker exec [CONTAINER] systemctl status smbd`
- Verify ports listening: `docker exec [CONTAINER] ss -tlnp | grep -E "445|137|138"`
- Test port accessibility from gateway: `nc -zv 24.204.72.65 445` (netcat, TCP port test)
- Verify firewall rules: Coordinate with Network Agent to check UFW/iptables
- Check user existence: `docker exec [CONTAINER] pdbedit -L -u [USERNAME]`
- Test user authentication: `docker exec [CONTAINER] smbclient //localhost/media -U [USERNAME] -c "ls"`
- Check user group membership: `docker exec [CONTAINER] id [USERNAME]`
- Verify share permissions: `docker exec [CONTAINER] ls -ld /media /backups /miscellanea`
- Query recent connections: `docker exec [CONTAINER] smbstatus -b` (current active connections)
- Check auth logs: `docker exec [CONTAINER] grep "authentication" /var/log/samba/log.* | tail -20`
- Diagnose share access denial: Check file permissions, user group, and `smb.conf` valid users
- Test from WireGuard peer via jumpbox: `ssh -L 445:24.204.72.65:445 jump@jumpbox` then SMB localhost
- Verify Pi-hole DNS resolution: Resolve Samba server hostname (if configured)

**Key Interfaces/Endpoints:**
- SMB client: `smbclient` (test SMB connections, list shares, browse files)
- Samba status: `smbstatus` (active connections, user sessions, locked files)
- User database: `pdbedit` (query Samba user information)
- System tools: `netstat`, `ss` (port listening status)
- Container exec: `docker exec [CONTAINER] [COMMAND]`
- Logs: `/var/log/samba/` (authentication, connection, error logs)
- Network test: `nc` (netcat), `ping`, `traceroute`

**Environment Variables/Config:**
- Standard SMB port: 445/tcp
- NetBIOS ports: 137-138/udp (optional, may not be needed)
- Samba service: `smbd` (main daemon)
- Config validation: `testparm /etc/samba/smb.conf`
- Common auth failure causes: Wrong password, user not in valid_users group, user disabled
- Common connection failure causes: Firewall blocking, service down, wrong IP/port
- Common share access failure causes: Permission bits, group membership, `smb.conf` restrictions

**Example Tasks:**
- Diagnose "connection refused" error when accessing 24.204.72.65:445
- Troubleshoot "permission denied" when accessing media share as user "empire"
- Verify service is running after container deployment
- Test access from WireGuard peer (SpaceBase at 24.204.72.66) via jumpbox
- Check if "media_users" group membership is causing share access issue
- Confirm firewall rule exists for port 445 (coordinate with Network Agent)
- Diagnose repeated failed authentication attempts (>5 in 5 minutes)
- Verify backup share is empty and ready for backup traffic

**Constraints:**
- Troubleshooting requires container access (docker exec commands)
- Some diagnostics require root/elevated privileges
- SMB authentication failures may be due to user/group/permission mismatch
- Firewall issues require Network Agent coordination
- Connection limits (max 10 concurrent) may block new connections if limit reached
- WireGuard access requires jumpbox setup and SSH tunneling (coordinate with WireGuard Agent)
- Some errors logged to `/var/log/samba/` may require container log examination
- Service restart may disconnect active users (coordinate timing)

---

### 6. Remote Access & Jumpbox Tunneling Skill

**Responsibilities:**
- Configure and manage SSH tunneling for remote Samba access via jumpbox
- Enable WireGuard peers to access Samba shares securely
- Manage jumpbox-to-Samba container connectivity
- Coordinate with WireGuard Agent for peer access control
- Document tunneling procedures for end users
- Monitor and troubleshoot remote access issues

**Capabilities:**
- Establish SMB port tunnel: `ssh -L 445:24.204.72.65:445 jump@jumpbox` (local port 445 → Samba 445)
- Establish NetBIOS name services tunnel: `ssh -L 137:24.204.72.65:137 -L 138:24.204.72.65:138 jump@jumpbox` (UDP tunnels)
- Connect to tunneled SMB: `smbclient //localhost/media -U empire` (after tunnel established)
- Verify jumpbox accessibility: `ssh -T jump@jumpbox` (test SSH connection)
- Verify Samba accessibility from jumpbox: `docker exec jumpbox nc -zv 24.204.72.65 445` (test from container)
- Test full remote access flow: Establish tunnel, connect to share, list files, verify write access
- Create persistent SSH tunnel: `ssh -N -L 445:24.204.72.65:445 jump@jumpbox &` (background tunnel)
- Monitor active tunnels: `netstat -tlnp | grep ssh` (show local SSH tunnels)
- Diagnose tunnel connection failure: Check jumpbox connectivity, Samba port accessibility
- Configure SSH key-based auth: Coordinate with WireGuard Agent for jumpbox access
- Document tunneling for end users: Provide connection instructions and example commands

**Key Interfaces/Endpoints:**
- Jumpbox container: SSH access at port 2222 (docker service/network)
- Samba containers: SMB ports 445/tcp, 137-138/udp on host network
- SSH tunneling: Local forwarding via `-L` flag
- SSH keys: Authentication via WireGuard Agent managed keys
- Tunneled SMB client: `smbclient` connecting to localhost (after tunnel)

**Environment Variables/Config:**
- Jumpbox SSH port: 2222 (external-facing, mapped from internal 22)
- Jumpbox hostname/IP: Accessible from WireGuard peers (24.204.72.x range)
- Samba server IPs: 24.204.72.65 (gateway) and 24.204.72.66 (SpaceBase)
- Samba SMB port: 445/tcp (tunneled via `-L 445:24.204.72.65:445`)
- Samba NetBIOS ports: 137-138/udp (optional tunneling, less common)
- SSH tunneling syntax: `-L [LOCAL_PORT]:[REMOTE_HOST]:[REMOTE_PORT]`
- Key-based auth: Coordinate with WireGuard Agent for SSH key management

**Example Tasks:**
- Create SSH tunnel to access media share from remote WireGuard peer (SpaceBase)
- Test remote access: Establish tunnel, connect to backup share, verify write access
- Verify jumpbox can reach Samba containers on both nodes (24.204.72.65 and 24.204.72.66)
- Troubleshoot "connection refused" on tunneled SMB port
- Document full access procedure: Tunnel setup, share connection, file operations
- Monitor remote access session: Check active tunnels and SMB connections
- Setup persistent tunnel for automated backup traffic

**Constraints:**
- Jumpbox SSH access required (managed by WireGuard Agent)
- SSH tunneling requires SSH client on remote machine (not all clients support SMB over SSH)
- Tunneled connections may have higher latency than direct access
- Port 445 must be available on local machine (no local Samba instance running)
- SSH key-based auth required (no password authentication)
- Each tunnel is single-user (scale with multiple SSH processes for concurrent users)
- Coordinate remote access procedures with WireGuard Agent for peer onboarding
- Failed authentication on tunneled connections may hide firewall issues
- NetBIOS services (137-138) rarely needed for modern SMB3 (port 445 sufficient)

---

### 7. Backup & Disaster Recovery Planning Skill

**Responsibilities:**
- Design and document backup strategy for Samba shares
- Coordinate with Prometheus Agent for backup scheduling
- Manage share configuration backups
- Plan disaster recovery procedures
- Monitor backup storage capacity and retention
- Coordinate with future backup infrastructure

**Capabilities:**
- Export share configuration: Backup `/etc/samba/smb.conf` to external storage
- Document user account list: Export via `docker exec [CONTAINER] pdbedit -L > user_export.txt`
- Verify share integrity: Check available space, file counts, recent modifications
- Plan backup method: Determine if full/incremental backup strategy (coordinated with Prometheus)
- Monitor backup storage: Track available capacity on backup share (1TB allocated)
- Document recovery procedure: Steps to restore Samba config and user database
- Coordinate backup timing: Work with Prometheus Agent to avoid metric collection conflicts
- Archive share snapshots: Plan for point-in-time recovery (future enhancement)
- Test restore procedure: Practice recovery from backup to verify completeness
- Document retention policy: Define how long backups are kept (currently 30+ days minimum)

**Key Interfaces/Endpoints:**
- Share configuration: `/etc/samba/smb.conf`
- User database: `/var/lib/samba/private/passdb.tdb` (binary, export via `pdbedit`)
- Backup location: External storage (TBD - when more capacity available)
- Prometheus coordination: Backup schedule alignment with metrics collection
- Backup tools: `tar`, `rsync`, `cp` (basic file backup commands)

**Environment Variables/Config:**
- Backup share path: `/backups` (1TB allocated for TimeMachine and system backups)
- Configuration backup: `/etc/samba/` (entire directory)
- User database backup: Export from `passdb.tdb` via `pdbedit` tool
- Log backup: `/var/log/samba/` (30-day retention minimum)
- Retention policy: TBD (coordinated with storage availability and Prometheus Agent)
- Backup frequency: TBD (future implementation)
- Restore point strategy: Daily snapshots? Weekly? (future definition)

**Example Tasks:**
- Export current `smb.conf` configuration to version control
- Create list of all Samba users and group memberships for documentation
- Verify backup share has sufficient space for incoming TimeMachine backups
- Document steps to restore Samba from backup configuration
- Plan coordinate backup schedule with Prometheus Agent (avoid metric impact)
- Identify critical data in miscellanea share that must be backed up
- Prepare disaster recovery runbook for Samba failure scenario

**Constraints:**
- Shares not currently backed up (first priority: storage infrastructure)
- User database recovery requires `pdbedit` export (cannot directly copy TDB file between versions)
- Configuration changes should be documented in version control (not just in smb.conf)
- Backup storage limited to 1TB allocated share (scalability TBD)
- Backup timing must be coordinated with Prometheus Agent (to prevent metric collection impact)
- Recovery procedure requires container restart (coordinate with active users)
- Future backups will follow Prometheus Agent backup coordination patterns
- Backup retention policy must balance with available storage capacity

---

## Diagnostic Workflows

### SMB Connection Refused Troubleshooting
1. **Symptom**: Client cannot connect to Samba server (connection refused, timeout, or host unreachable)
2. **Steps**:
   - Verify Samba service is running: `docker exec [CONTAINER] systemctl status smbd` (check "active" status)
   - Check SMB port 445 is listening: `docker exec [CONTAINER] ss -tlnp | grep 445` (should show smbd listening)
   - Test connectivity from gateway: `nc -zv 24.204.72.65 445` (TCP port accessibility test)
   - Verify firewall allows port 445: Coordinate with Network Agent; check `sudo ufw status` for rule
   - If firewall rule missing: Contact Network Agent to add rule for port 445/tcp to internal network
   - If port not listening: Check container logs: `docker logs [CONTAINER]` (service startup errors)
   - Verify container is running: `docker ps | grep samba` (must be in "running" state)
   - If container stopped: Restart: `docker service update --force samba` (restart via Docker)
   - If service running but port not listening: Check `smb.conf` configuration: `docker exec [CONTAINER] testparm` (syntax/config errors)
   - From WireGuard peer: Verify jumpbox tunnel: `ssh -L 445:24.204.72.65:445 jump@jumpbox` (tunnel establishment)
   - After tunnel: Test `smbclient //localhost/media -U -c "ls"` (verify tunnel + SMB)
   - Recommend: Fix service, restart container, update firewall rules, or establish jumpbox tunnel

### Authentication Failed Troubleshooting
1. **Symptom**: User cannot login (authentication failed, invalid username/password)
2. **Steps**:
   - Verify user exists: `docker exec [CONTAINER] pdbedit -L -u [USERNAME]` (check Samba user database)
   - Check user is enabled: `docker exec [CONTAINER] pdbedit -L | grep [USERNAME]` (should not show "D" flag = disabled)
   - Verify password: User password may have expired or incorrect entry
   - Reset password: `docker exec [CONTAINER] smbpasswd [USERNAME]` (prompt for new password)
   - Check user group membership: `docker exec [CONTAINER] id [USERNAME]` (groups should match share `valid users`)
   - Verify user in correct group: If accessing media share, user should be in `media_users` group
   - Add user to group: `docker exec [CONTAINER] usermod -a -G media_users [USERNAME]` (add to group)
   - Check share valid_users: `docker exec [CONTAINER] grep -A 5 "^\[media\]" /etc/samba/smb.conf` (verify `valid users = @media_users`)
   - Test authentication: `docker exec [CONTAINER] smbclient //localhost/media -U [USERNAME]` (try login with correct share)
   - Check failed auth logs: `docker exec [CONTAINER] grep "authentication" /var/log/samba/log.* | tail -10` (recent auth failures)
   - Count failed attempts: Alert if >5 failures in 5-minute window (potential security issue)
   - Verify no account lockout: Samba (unlike AD) doesn't have account lockout; check for disabled flag
   - Recommend: Reset password, verify group membership, check share configuration, or investigate failed auth pattern

### Share Permission Denied Troubleshooting
1. **Symptom**: User authenticated but cannot access share or files (permission denied)
2. **Steps**:
   - Verify user is in correct group: `docker exec [CONTAINER] id [USERNAME]` (check group membership)
   - Check share valid_users: `docker exec [CONTAINER] grep "valid users" /etc/samba/smb.conf | grep -A 1 "^\[media\]"` (verify user/group listed)
   - Check file permissions: `docker exec [CONTAINER] ls -ld /media` (should be drwxrwx--- or similar, group writable)
   - Verify group ownership: `docker exec [CONTAINER] ls -ld /media` (group column should be media_users)
   - Check ACLs: `docker exec [CONTAINER] getfacl /media` (view access control lists)
   - List directory contents: `docker exec [CONTAINER] ls -la /media` (check if files are group-readable)
   - Test file access: `docker exec [CONTAINER] smbclient //localhost/media -U [USERNAME] -c "ls"` (browse from SMB client)
   - If still denied: Check SMB config "write list" setting: `grep "write list\|read list" /etc/samba/smb.conf`
   - Verify writable flag: `grep "writable" /etc/samba/smb.conf | head -1` (should be "yes" for media/backup shares)
   - Check umask: Files created with restrictive umask may prevent group access
   - Recommend: Fix group membership, file permissions, share configuration, or ACLs

### Share Capacity Approaching Limit Troubleshooting
1. **Symptom**: Share running out of space (>90% full); new writes may fail
2. **Steps**:
   - Check share usage: `docker exec [CONTAINER] du -sh /media /backups /miscellanea` (disk usage per share)
   - Identify large files: `docker exec [CONTAINER] find /media -type f -size +1G` (files >1GB)
   - Check available space: `docker exec [CONTAINER] df -h | grep -E "media|backups|miscella"` (total/available on mount)
   - Calculate free percentage: (available / total) * 100 (alert if <10% free space)
   - Identify high-usage users: Query Prometheus metrics `samba_share_io_bytes_written_total` (who's writing most)
   - Check for stale files: Find and archive older files not accessed recently
   - Plan storage expansion: Coordinate with Docker Agent for additional volume/storage
   - Monitor with Prometheus: Alert should fire when >90% capacity (`samba_share_used_bytes` / `samba_share_capacity_bytes` > 0.9)
   - Coordinate backup strategy: Backups should clean up old files to make space
   - Recommend: Archive/delete old files, expand storage, or implement quota policy

### Exporter Metric Collection Failure Troubleshooting
1. **Symptom**: Prometheus cannot scrape Samba metrics; missing `samba_*` metrics in target
2. **Steps**:
   - Verify exporter script exists: `ls -l /usr/local/bin/samba-exporter.sh` (file must exist, be executable)
   - Check script permissions: Must be 755 (owner can execute)
   - Test script execution: `/usr/local/bin/samba-exporter.sh` (should output Prometheus format metrics)
   - Check output format: Look for `# HELP` and `# TYPE` lines (Prometheus documentation lines)
   - Verify metric names: Should start with `samba_` prefix (e.g., `samba_connections_total`)
   - Check script timeout: Measure execution time; should complete in <10 seconds
   - If slow: Optimize `smbstatus` queries or reduce metric granularity
   - Verify script log: Check `/var/log/samba-exporter.log` for errors or warnings
   - Check Prometheus config: Verify scrape target includes Samba metrics endpoint
   - Coordinate with Prometheus Agent: Notify if exporter format changed
   - Test from Prometheus: `curl http://[SAMBA_IP]:9100/metrics` (if using node_exporter textfile collector)
   - Recommend: Fix script, permissions, or coordinate with Prometheus Agent for scrape configuration

---

## Best Practices

- ✓ Always validate `smb.conf` with `testparm` before restarting Samba service
- ✓ Create regular exports of user database (`pdbedit -L`) for audit and documentation
- ✓ Test share access after any permission or group changes
- ✓ Use group-based access control (simpler to manage than per-user ACLs)
- ✓ Keep admin password secure; store `samba_admin` credentials in encrypted Docker volume
- ✓ Monitor failed authentication attempts; alert on >5 failures in 5 minutes (potential attack)
- ✓ Coordinate backup timing with Prometheus Agent to avoid metric collection conflicts
- ✓ Document all share purposes and access requirements in this skills file
- ✓ Test remote access via jumpbox tunneling before deploying to production
- ✓ Maintain version control of `smb.conf` configuration (track changes over time)
- ✓ Plan for future backup infrastructure (coordinate with Prometheus when ready)
- ✓ Keep Samba version current (4.19.5 or later for SMB3 support and security)

---

## Validation Checklist

Before deploying Samba Agent changes, verify:

- [ ] Samba containers deployed on both nodes (24.204.72.65 and 24.204.72.66)
- [ ] SMB port 445/tcp and NetBIOS 137-138/udp are listening
- [ ] Firewall rules allow SMB traffic on port 445 (coordinated with Network Agent)
- [ ] All three shares (media, backups, miscellanea) are configured and accessible
- [ ] Admin user `samba_admin` is created with secure password
- [ ] Service accounts created with random long passwords (stored in encrypted volumes)
- [ ] Groups created: `media_users`, `backup_users`, `all_users`
- [ ] Example user "empire" created and added to appropriate group
- [ ] Share permissions set correctly (group ownership, rwx bits, ACLs)
- [ ] Test share access from internal network user account
- [ ] Samba exporter script `/usr/local/bin/samba-exporter.sh` is executable and working
- [ ] Prometheus scrapes Samba metrics successfully (no missing metrics)
- [ ] Alert rules configured for failed auth (>5 attempts), capacity (>90% full), service down
- [ ] Jumpbox SSH tunneling tested for remote WireGuard peer access
- [ ] Container logs show no errors on startup
- [ ] `smbstatus -b` shows expected active connections
- [ ] User/group database verified: `pdbedit -L` lists expected accounts
- [ ] Configuration file `/etc/samba/smb.conf` validated: `testparm` passes
- [ ] No guest access allowed (all shares require authentication)
- [ ] Log rotation configured for `/var/log/samba/` (30+ day retention)
- [ ] Backup share (1TB) has sufficient free space for incoming backups

---

## Reference Implementation

**Live Examples:**
- `DOCKER_AGENT_SKILLS.md` - Container deployment, service management, jumpbox networking
- `NETWORK_AGENT_SKILLS.md` - Firewall rules coordination, SMB port 445/tcp, NetBIOS 137-138/udp
- `PROMETHEUS_AGENT_SKILLS.md` - Metrics collection, alerting, custom exporter coordination
- `WIREGUARD_AGENT_SKILLS.md` - Peer access via jumpbox, SSH key management, encrypted tunneling

**When deploying Samba Agent:**
1. Coordinate with Docker Agent to deploy containers on both nodes (24.204.72.65 and 24.204.72.66)
2. Verify with Network Agent that firewall rules allow SMB traffic (port 445/tcp, 137-138/udp)
3. Create admin user `samba_admin` and service accounts with secure credentials
4. Configure all three shares with group-based access control
5. Deploy custom Prometheus exporter script `/usr/local/bin/samba-exporter.sh`
6. Setup Prometheus Agent to scrape Samba metrics at 15-second interval
7. Create alert rules with Prometheus Agent (failed auth, capacity, service health)
8. Test remote access via jumpbox tunneling with WireGuard Agent coordination
9. Document user access procedures and share purposes
10. Monitor active connections and usage patterns (verify <10 concurrent connection limit)
11. Plan future backup coordination with Prometheus Agent (when storage available)
12. Conduct security audit of user accounts and group memberships

**When adding a new user:**
1. Create system user: `docker exec [CONTAINER] useradd -m [USERNAME]`
2. Create Samba user: `docker exec [CONTAINER] smbpasswd -a [USERNAME]`
3. Add to appropriate group: `docker exec [CONTAINER] usermod -a -G media_users [USERNAME]`
4. Test access: `docker exec [CONTAINER] smbclient //localhost/media -U [USERNAME] -c "ls"`
5. Document user in version control (maintain access matrix)

**When monitoring share capacity:**
1. Query usage: `docker exec [CONTAINER] du -sh /media /backups /miscellanea`
2. Check Prometheus metrics: `samba_share_used_bytes` / `samba_share_capacity_bytes`
3. Alert if >90% full (configure in Prometheus Agent alert rules)
4. Plan remediation: Archive old files, expand storage, or implement quota

**When troubleshooting remote access:**
1. Verify jumpbox SSH access: `ssh -T jump@jumpbox` (should succeed)
2. Establish SMB tunnel: `ssh -L 445:24.204.72.65:445 jump@jumpbox`
3. Test from local machine: `smbclient //localhost/media -U [USERNAME]`
4. If failed: Check firewall rules, Samba service status, and user/group membership
5. Coordinate with WireGuard Agent for jumpbox and peer configuration

**When coordinating backup strategy:**
1. Determine backup method (full/incremental, retention policy)
2. Work with Prometheus Agent to align backup schedule (avoid metric conflicts)
3. Verify backup share (1TB) has sufficient space
4. Document recovery procedure for configuration and user database
5. Test restore from backup to verify completeness
6. Plan for future backup automation (when storage infrastructure ready)

---

## Questions to Guide Samba Operations

When managing Samba shares, ask:

1. **What is the share purpose?** (Media, backups, information repository?)
2. **Who needs access?** (Specific users, groups, internal network only?)
3. **What permissions are needed?** (Read-only, read/write, modify?)
4. **Is backup required?** (Plan backup strategy and retention)
5. **What is the expected usage?** (Concurrent users, I/O patterns, growth rate?)
6. **How should remote access work?** (Jumpbox tunneling, VPN coordination?)
7. **What alerts are needed?** (Failed auth, capacity, service health?)
8. **How is authentication coordinated?** (User creation, password rotation, group management?)
9. **What is the disaster recovery plan?** (Restore from backup, RTO/RPO targets?)
10. **Is this coordinated with other agents?** (Docker for containers, Network for firewall, Prometheus for metrics, WireGuard for peers?)

Answer these for each Samba operation, and you'll maintain secure, accessible, monitored file sharing across the infrastructure.

---

## Known Limitations & Gotchas

- **SMB3 Negotiation**: Older clients may not support SMB3; verify compatibility before deploying
- **Guest Access Disabled**: All connections require authentication (no anonymous access)
- **Connection Limit**: Maximum 10 concurrent SMB connections total (enforced at Samba config level)
- **Container Restart**: Restarts reset active connections and metrics (coordinate timing)
- **User Database**: `passdb.tdb` is binary; export via `pdbedit` for backup/migration
- **Backup Share**: Currently limited to 1TB (future expansion dependent on storage availability)
- **NetBIOS Services**: Ports 137-138/udp rarely needed for modern SMB3 clients (port 445 sufficient)
- **Performance**: Heavy I/O on media or miscellanea shares may impact Prometheus metric collection
- **Configuration Changes**: All changes to `smb.conf` require container restart (potential service downtime)
- **Remote Access**: WireGuard peers must use jumpbox SSH tunneling (direct SMB access not available outside network)

---

**Last Updated**: September 16, 2026
**Version**: 1.0
**Network**: 24.204.72.64/26 (internal only)
**SMB Port**: 445/tcp (primary), 137-138/udp (NetBIOS, optional)
**Containers**: 2 (running on nodes 24.204.72.65 and 24.204.72.66)
**Shares**: 3 (media 1.990TB, backups 1TB, miscellanea unlimited)
**Concurrent Users**: Max 10 SMB connections
**Samba Version**: 4.19.5-Ubuntu (from official samba:latest Docker image)
