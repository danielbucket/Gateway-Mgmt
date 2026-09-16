# Security & Secrets Agent - Validation Checklist

**Status**: 🟡 Ready for Testing  
**Last Validation**: [To be filled during deployment]  
**Validated By**: [Security & Infrastructure Team]  
**Next Review**: [90 days post-deployment]

---

## Pre-Deployment Validation

### Installation & Configuration

- [ ] **INST-001**: Vault binary installed and executable
  - **Verification**: `which vault && vault version`
  - **Expected Result**: Version 1.15.0+ displayed
  - **Critical**: Yes - deployment blocker

- [ ] **INST-002**: Vault configuration file created and valid
  - **Verification**: `vault config validate /etc/vault/vault.hcl`
  - **Expected Result**: Configuration is valid
  - **Critical**: Yes - deployment blocker

- [ ] **INST-003**: Persistent storage backend configured
  - **Verification**: Connect to database/S3 backend
  - **Expected Result**: Storage backend responds, empty or ready
  - **Critical**: Yes - data loss risk

- [ ] **INST-004**: TLS certificates generated
  - **Verification**: `openssl x509 -in /etc/vault/tls.crt -text -noout`
  - **Expected Result**: Certificate valid, CN=vault.internal, 365+ days remaining
  - **Critical**: Yes - security requirement

- [ ] **INST-005**: Vault service file created
  - **Verification**: `test -f /etc/systemd/system/vault.service && systemctl status vault`
  - **Expected Result**: Service file present and recognized
  - **Critical**: Yes - startup automation

- [ ] **INST-006**: Environment variables configured
  - **Verification**: `cat /etc/vault/vault.env | grep VAULT_`
  - **Expected Result**: VAULT_ADDR, VAULT_TOKEN (if test user), vault-related vars present
  - **Critical**: No - helpful for operations

### Health Checks

- [ ] **HEALTH-001**: Vault process/service can start
  - **Verification**: `sudo systemctl start vault && sleep 2 && systemctl is-active vault`
  - **Expected Result**: active (running)
  - **Critical**: Yes - deployment blocker

- [ ] **HEALTH-002**: Vault API responding (unsealed)
  - **Verification**: `curl -k https://localhost:8200/v1/sys/health | jq .sealed`
  - **Expected Result**: `false` (unsealed state), HTTP 200
  - **Critical**: Yes - core functionality

- [ ] **HEALTH-003**: Audit logging enabled and operational
  - **Verification**: `vault audit list` shows audit backend active
  - **Expected Result**: file audit backend listed, Path=/audit
  - **Critical**: Yes - compliance requirement

- [ ] **HEALTH-004**: No critical errors in startup logs
  - **Verification**: `journalctl -u vault -n 100 | grep -i error`
  - **Expected Result**: No ERROR or FATAL entries
  - **Critical**: Yes - indicates misconfiguration

- [ ] **HEALTH-005**: Vault using correct storage backend
  - **Verification**: `curl -k https://localhost:8200/v1/sys/config/state | jq .data.storage_type`
  - **Expected Result**: Shows configured backend type (postgres, s3, etc.)
  - **Critical**: Yes - wrong backend = data loss risk

### Connectivity

- [ ] **CONN-001**: Storage backend reachable from all vault nodes
  - **Dependency**: PostgreSQL/S3/etc backend
  - **Verification**: From each node: `psql -h db.internal ...` or `aws s3 ls s3://vault-backend/`
  - **Expected Result**: Database/S3 connectivity successful from all nodes
  - **Critical**: Yes - cluster cannot form without storage

- [ ] **CONN-002**: Network connectivity between vault nodes (Raft)
  - **Dependency**: Intra-cluster communication
  - **Verification**: From Node 1: `telnet vault-node-2 8201` and `telnet vault-node-3 8201`
  - **Expected Result**: Port 8201 open on all nodes, can connect
  - **Critical**: Yes - cluster formation requirement

- [ ] **CONN-003**: API ports open and listening
  - **Verification**: `netstat -tlnp | grep 8200` (should show vault)
  - **Expected Result**: Port 8200 LISTEN on all interfaces (or restricted as configured)
  - **Critical**: Yes - clients need API access

- [ ] **CONN-004**: HSM reachable (if using HSM)
  - **Dependency**: Optional hardware security module
  - **Verification**: `opensc-tool -l` (if using HSM) or test HSM connectivity
  - **Expected Result**: HSM present and responding
  - **Critical**: Only if HSM configured - deployment blocker if configured

- [ ] **CONN-005**: Central logging system reachable
  - **Dependency**: Splunk/ELK/logging backend
  - **Verification**: `curl -I https://logging.internal:8088/`
  - **Expected Result**: HTTP 200/401 (auth required is OK)
  - **Critical**: No - but important for compliance

### Resource Allocation

- [ ] **RESOURCE-001**: CPU allocation adequate
  - **Target**: Minimum 2 cores, recommended 4
  - **Verification**: `nproc` shows available CPUs, `lscpu` shows CPU details
  - **Expected Result**: ≥ 2 cores available per node
  - **Critical**: Yes - performance requirement

- [ ] **RESOURCE-002**: Memory allocation adequate
  - **Target**: Minimum 4 GB, recommended 8 GB
  - **Verification**: `free -h` shows total memory
  - **Expected Result**: ≥ 4 GB available per node
  - **Critical**: Yes - OOM risk if under-provisioned

- [ ] **RESOURCE-003**: Disk space adequate
  - **Target**: Minimum 50 GB, recommended 100 GB
  - **Verification**: `df -h /opt/vault` and `df -h` (storage backend mount)
  - **Expected Result**: ≥ 50 GB free on vault disk, ≥ 100 GB on storage backend
  - **Critical**: Yes - data loss if disk fills

- [ ] **RESOURCE-004**: Network bandwidth adequate
  - **Target**: 1 Gbps redundant links
  - **Verification**: Network interface speed `ethtool eth0 | grep Speed`
  - **Expected Result**: ≥ 1000 Mb/s
  - **Critical**: No - affects performance but not functionality

---

## Skill Validation

### Skill Group 1: Core Security Infrastructure

#### Skill 1: Secret Management & Vault Setup

- [ ] **SK-SEC-001**: Vault initialized with 5 unseal keys (threshold 3)
  - **Verification**: `vault operator key-status` or `vault status` shows "Initialized: true"
  - **Expected Result**: Initialization complete, unseal keys created
  - **Acceptance Criteria**:
    - [ ] Vault returns initialized status
    - [ ] 5 unseal keys created (or configured threshold)
    - [ ] Key shares distributed to custodians
    - [ ] Root token stored securely
  - **Critical**: Yes - one-time initialization

- [ ] **SK-SEC-002**: Secret storage operational
  - **Verification**: `vault write secret/data/test-secret foo=bar` then `vault read secret/data/test-secret`
  - **Expected Result**: Secret stored and retrieved successfully
  - **Acceptance Criteria**:
    - [ ] Write succeeds
    - [ ] Read retrieves same value
    - [ ] No errors in logs
    - [ ] Audit log shows both operations
  - **Critical**: Yes - core functionality

- [ ] **SK-SEC-003**: Secret lifecycle working (rotation)
  - **Verification**: `vault write -f secret/data/rotating-secret-v2` (create new version) then verify old version still accessible
  - **Expected Result**: Secret versioning works, old versions retained
  - **Acceptance Criteria**:
    - [ ] New version created
    - [ ] Old version still readable
    - [ ] Metadata shows version history
    - [ ] List operation shows all versions
  - **Critical**: Yes - operational requirement

- [ ] **SK-SEC-004**: Backup & restore working
  - **Verification**: `vault operator raft snapshot save test.snap` then on test system `vault operator raft snapshot restore test.snap`
  - **Expected Result**: Backup created successfully, restore completes without error
  - **Acceptance Criteria**:
    - [ ] Snapshot file created
    - [ ] File size > 1 MB (indicates data)
    - [ ] File is readable
    - [ ] Restore succeeds
    - [ ] Secrets available post-restore
  - **Critical**: Yes - DR requirement

#### Skill 2: Encryption Key Management

- [ ] **SK-ENC-001**: Master key generated and secured
  - **Verification**: `vault read transit/keys/master | grep -A 5 keys` shows key data
  - **Expected Result**: Master key present, key type correct
  - **Acceptance Criteria**:
    - [ ] Transit engine enabled
    - [ ] Master key exists
    - [ ] Key ID shown in output
    - [ ] Key marked as active latest version
  - **Critical**: Yes - encryption foundation

- [ ] **SK-ENC-002**: Data encryption/decryption working
  - **Verification**: `vault write transit/encrypt/master plaintext=@secret.txt` then `vault write transit/decrypt/master ciphertext=<ciphertext>`
  - **Expected Result**: Encryption produces ciphertext, decryption recovers plaintext
  - **Acceptance Criteria**:
    - [ ] Plaintext encrypted to ciphertext
    - [ ] Ciphertext format correct (base64)
    - [ ] Decryption recovers original plaintext
    - [ ] No errors during en/decryption
  - **Critical**: Yes - core functionality

- [ ] **SK-ENC-003**: Key rotation working
  - **Verification**: `vault write -f transit/keys/master/rotate` then `vault read transit/keys/master | grep key_version`
  - **Expected Result**: New key version created, old version retained
  - **Acceptance Criteria**:
    - [ ] Rotation completes successfully
    - [ ] New key version appears
    - [ ] Latest version increments
    - [ ] Old data still decryptable with previous version
  - **Critical**: Yes - rotation requirement

- [ ] **SK-ENC-004**: HSM integration working (if configured)
  - **Verification**: If HSM in use: `echo "test" | pkcs11-tool --sign --mechanism SHA256-RSA-PKCS`
  - **Expected Result**: HSM accepts request and signs data
  - **Acceptance Criteria**:
    - [ ] HSM responds without timeout
    - [ ] Signature generated
    - [ ] Performance acceptable (< 500ms)
    - [ ] No auth errors
  - **Critical**: Only if HSM configured

### Skill Group 2: Access & Authentication

#### Skill 3: SSH Key & Certificate Management

- [ ] **SK-SSH-001**: SSH key pairs generated
  - **Verification**: `vault read ssh/keys/user-key` should show public key
  - **Expected Result**: SSH key pair present in vault
  - **Acceptance Criteria**:
    - [ ] SSH engine enabled
    - [ ] Key pair exists
    - [ ] Public key format correct (openssh format)
    - [ ] Private key stored securely in vault
  - **Critical**: Yes - authentication foundation

- [ ] **SK-SSH-002**: SSH certificate sign working
  - **Verification**: `vault write ssh/sign/user-role public_key=@user_key.pub` should return signed certificate
  - **Expected Result**: Certificate signed and returned
  - **Acceptance Criteria**:
    - [ ] Certificate generated
    - [ ] Certificate valid for expected lifetime
    - [ ] Can verify certificate structure
    - [ ] SSH CA config correct
  - **Critical**: Yes - certificate auth

- [ ] **SK-SSH-003**: TLS certificate generation working
  - **Verification**: `vault write pki/issue/api-cert common_name=api.internal`
  - **Expected Result**: Certificate issued with correct CN and alt names
  - **Acceptance Criteria**:
    - [ ] Certificate issued successfully
    - [ ] CN matches requested
    - [ ] Alt names populated
    - [ ] Key included in response
    - [ ] Certificate valid for 90+ days
  - **Critical**: Yes - TLS for services

- [ ] **SK-SSH-004**: Certificate renewal working
  - **Verification**: Generate certificate, monitor expiration, trigger renewal before expiry
  - **Expected Result**: Certificate renewed before expiration
  - **Acceptance Criteria**:
    - [ ] Renewal triggered at 30 days before expiry
    - [ ] New certificate issued
    - [ ] Services notified of new certificate
    - [ ] No service interruption during renewal
  - **Critical**: Yes - prevents cert expiry outages

#### Skill 4: Access Control Policies (RBAC)

- [ ] **SK-RBAC-001**: Policies created and assigned to roles
  - **Verification**: `vault policy list` shows all expected policies
  - **Expected Result**: Policies for admin, operator, developer, service accounts, viewer
  - **Acceptance Criteria**:
    - [ ] At least 5 policies defined
    - [ ] Each policy has documented purpose
    - [ ] Policy syntax valid (vault policy validate)
    - [ ] Policies follow least-privilege principle
  - **Critical**: Yes - security foundation

- [ ] **SK-RBAC-002**: Service account tokens issued with correct policies
  - **Verification**: `vault token create -policy=docker-agent -ttl=24h` should return token, then verify token policies: `vault token lookup <token> | grep policies`
  - **Expected Result**: Token issued with expected policy, policy list correct
  - **Acceptance Criteria**:
    - [ ] Token generated successfully
    - [ ] TTL set correctly (24h for this example)
    - [ ] Policy assignment verified
    - [ ] Token works for intended operations
    - [ ] Token denied for non-allowed operations
  - **Critical**: Yes - authorization enforcement

- [ ] **SK-RBAC-003**: Unauthorized access denied with audit trail
  - **Verification**: Attempt to read secret with token lacking permission: `vault read secret/data/admin-only --token=<limited-token>`
  - **Expected Result**: Request denied with 403 Forbidden
  - **Acceptance Criteria**:
    - [ ] Request denied with 403 status
    - [ ] Clear error message
    - [ ] Denial logged in audit log
    - [ ] Audit shows who/what/when
  - **Critical**: Yes - security enforcement

- [ ] **SK-RBAC-004**: Break-glass procedure documented and testable
  - **Verification**: Review break-glass procedure document, simulate emergency access scenario
  - **Expected Result**: Procedure clear, emergency access grantable, audit trail complete
  - **Acceptance Criteria**:
    - [ ] Procedure documented
    - [ ] Approval workflow defined
    - [ ] Emergency access issuable
    - [ ] Elevated access logged
    - [ ] Time limit enforced
  - **Critical**: Yes - emergency requirement

### Skill Group 3: Compliance & Operations

#### Skill 5: Compliance & Audit Logging

- [ ] **SK-AUDIT-001**: Audit logging enabled and operational
  - **Verification**: `vault audit list` and check that logs are being written: `ls -lh /var/log/vault/audit.log` should show recent modification
  - **Expected Result**: Audit backend listed, log file growing
  - **Acceptance Criteria**:
    - [ ] Audit backend enabled
    - [ ] Log file present and writable
    - [ ] File modified recently (within last hour)
    - [ ] Log file size > 1 MB
  - **Critical**: Yes - compliance requirement

- [ ] **SK-AUDIT-002**: Audit log contains expected events
  - **Verification**: Review audit log: `tail -100 /var/log/vault/audit.log | jq '.request.path'` should show various operations
  - **Expected Result**: Audit log shows secret reads, writes, policy changes
  - **Acceptance Criteria**:
    - [ ] Secret operations logged
    - [ ] Auth operations logged
    - [ ] Policy changes logged
    - [ ] Each entry includes timestamp
    - [ ] Each entry includes user/token info
  - **Critical**: Yes - forensics requirement

- [ ] **SK-AUDIT-003**: Audit logs immutable and protected
  - **Verification**: Attempt to edit audit log: `echo "fake" >> /var/log/vault/audit.log` should be denied or detected
  - **Expected Result**: Edit attempt blocked or audit integrity check fails
  - **Acceptance Criteria**:
    - [ ] Write-once storage (ideal)
    - [ ] Or integrity checking (hmac/signature)
    - [ ] Deletion attempt detected
    - [ ] Alert triggered on tampering
  - **Critical**: Yes - audit integrity

- [ ] **SK-AUDIT-004**: Centralized logging integration working
  - **Verification**: Check logging system (Splunk/ELK): Search for vault events from last hour
  - **Expected Result**: Vault audit logs appearing in central system
  - **Acceptance Criteria**:
    - [ ] Logs forwarded successfully
    - [ ] No delay (< 5 seconds)
    - [ ] All fields parsed correctly
    - [ ] Searchable by timestamp/user/operation
  - **Critical**: No - but important for SOC/SIEM

#### Skill 6: Security Incident Response

- [ ] **SK-INCIDENT-001**: Incident response procedures documented
  - **Verification**: Review incident response runbook at `/opt/vault/docs/incident-response.md`
  - **Expected Result**: Clear procedures for credential revocation, key rotation, access investigation
  - **Acceptance Criteria**:
    - [ ] Procedures documented in markdown/wiki
    - [ ] Multiple scenario types covered
    - [ ] Step-by-step instructions provided
    - [ ] Escalation path defined
  - **Critical**: Yes - operational requirement

- [ ] **SK-INCIDENT-002**: Credential revocation working
  - **Verification**: Create token, verify access works, revoke token: `vault token revoke <token>`, then verify access denied
  - **Expected Result**: Token successfully revoked, access denied with 403
  - **Acceptance Criteria**:
    - [ ] Token revocation succeeds
    - [ ] Revoked token immediately denied
    - [ ] Revocation logged
    - [ ] Related tokens also revoked (if configured)
  - **Critical**: Yes - incident response capability

- [ ] **SK-INCIDENT-003**: Emergency key rotation testable
  - **Verification**: Simulate compromised key: Document current key, rotate to new key, verify old key still allows read (for backward compatibility)
  - **Expected Result**: New key version created, old key still functional
  - **Acceptance Criteria**:
    - [ ] New key created without downtime
    - [ ] Rotation completes in < 30 seconds
    - [ ] Old encrypted data still decryptable
    - [ ] New data uses new key
  - **Critical**: Yes - security requirement

- [ ] **SK-INCIDENT-004**: Post-incident investigation possible
  - **Verification**: Review audit trail for compromised token: Search for all operations by that token
  - **Expected Result**: Complete timeline of compromised token activity
  - **Acceptance Criteria**:
    - [ ] Audit logs retained for 1+ year
    - [ ] Query by token ID works
    - [ ] Results show what secrets accessed
    - [ ] Timestamps and IP addresses captured
  - **Critical**: Yes - forensics requirement

---

## Integration Validation

### Upstream Dependencies

- [ ] **UP-001**: Storage & Backup Agent integration
  - **Dependency**: Backup capability, encrypted storage
  - **Test**: Create vault snapshot, initiate backup: `vault operator raft snapshot save backup.snap` then verify backup job captures it
  - **Success Criteria**: Snapshot created, backup job includes snapshot file
  - **Data Flow**: Vault data → Backup system → Encrypted storage
  - **Expected Latency**: Backup initiated within 1 minute of snapshot creation
  - **Critical**: Yes - recovery capability

- [ ] **UP-002**: Network Infrastructure Agent integration
  - **Dependency**: Network routing, DNS for vault.internal
  - **Test**: Verify DNS resolution: `nslookup vault-1.internal`, `nslookup vault-2.internal`
  - **Success Criteria**: All vault nodes resolvable by FQDN
  - **Data Flow**: Clients → DNS → Vault endpoints
  - **Expected Latency**: DNS query < 100ms
  - **Critical**: Yes - client connectivity

### Downstream Dependencies

- [ ] **DOWN-001**: Docker Agent can retrieve secrets
  - **Consumer**: Docker Agent for container image pull secrets
  - **Test**: From Docker host: `curl -k -H "X-Vault-Token: <token>" https://vault:8200/v1/secret/data/docker/registry`
  - **Success Criteria**: Secret retrieved successfully, contains registry credentials
  - **Data Format**: JSON with username/password fields
  - **Critical**: Yes - service authentication

- [ ] **DOWN-002**: All phase 2+ agents can authenticate to vault
  - **Consumer**: Logging, Service Mesh, Jumpbox, Pi-hole, and Phase 3/4 agents
  - **Test**: Create auth token for each agent type, verify can read their respective secrets
  - **Success Criteria**: All agents get tokens, can retrieve assigned secrets
  - **Data Format**: Vault API token format
  - **Critical**: Yes - operational requirement

- [ ] **DOWN-003**: Application services can retrieve credentials
  - **Consumer**: Any service needing database/API credentials
  - **Test**: Deploy test application configured with vault agent, verify secrets injected
  - **Success Criteria**: Application receives secrets in environment variables or files
  - **Data Format**: Environment variables or mounted files
  - **Critical**: Yes - application functionality

### Cross-Domain Integrations

- [ ] **CROSS-001**: Audit & Validation Agent can verify policies
  - **Domain**: Quality domain
  - **Verification**: Audit agent queries all policies: `vault policy list` and validates they comply with standards
  - **Expected Result**: All policies reviewed, compliance report generated
  - **Critical**: No - but important for compliance

- [ ] **CROSS-002**: Prometheus Agent can scrape vault metrics
  - **Domain**: Observability domain
  - **Verification**: Prometheus scrape endpoint active: `curl -s https://vault:8200/v1/sys/metrics`
  - **Expected Result**: Prometheus metrics in proper format
  - **Critical**: No - but important for monitoring

---

## Operational Validation

### Startup & Shutdown

- [ ] **OP-STARTUP-001**: Normal startup successful
  - **Procedure**: `sudo systemctl start vault`
  - **Verification**: `systemctl is-active vault` shows active
  - **Expected**: Service running, no error logs
  - **Time to Ready**: < 30 seconds from start to API responsive

- [ ] **OP-STARTUP-002**: Startup after crash/restart
  - **Procedure**: Kill vault process, verify restart: `sudo systemctl status vault` should show restarting
  - **Verification**: Vault API responsive within 60 seconds
  - **Expected**: Automatic restart via systemd, clean recovery

- [ ] **OP-STARTUP-003**: Cold start (all nodes down then up)
  - **Procedure**: Stop all vault nodes, restart one at a time
  - **Verification**: Cluster reforms with first node as leader
  - **Expected**: Cluster operational with 3/3 nodes healthy

- [ ] **OP-SHUTDOWN-001**: Clean shutdown successful
  - **Procedure**: `sudo systemctl stop vault`
  - **Verification**: Process stopped: `ps aux | grep vault` shows no vault process
  - **Expected**: No error logs, resources released

- [ ] **OP-SHUTDOWN-002**: In-flight data protected during shutdown
  - **Procedure**: Start write operation, immediately stop vault
  - **Verification**: Restart and verify data consistency
  - **Expected**: No data loss, write completed or rolled back

### Performance

- [ ] **PERF-001**: API response time < 100ms
  - **SLA**: 100ms max latency for secret reads
  - **Test**: `ab -n 1000 -c 50 http://vault:8200/v1/sys/health`
  - **Result**: Measure response times
  - **Pass Criteria**: 95th percentile < 100ms

- [ ] **PERF-002**: No memory leaks under load
  - **Test Duration**: 1 hour load test
  - **Load**: 100 requests/second
  - **Verification**: Memory usage monitored via `top` or prometheus
  - **Pass Criteria**: Memory growth < 5% over test duration

- [ ] **PERF-003**: Cluster replication latency acceptable
  - **Test**: Write secret to leader, measure time to appearance on replica
  - **Expected**: < 100ms replication lag
  - **Pass Criteria**: Raft consensus < 100ms

### Monitoring & Alerting

- [ ] **MON-001**: Prometheus metrics exported
  - **Metric Endpoint**: https://vault:8200/v1/sys/metrics
  - **Verification**: `curl -s https://vault:8200/v1/sys/metrics | head -20`
  - **Expected**: Metrics in Prometheus text format (HELP/TYPE/data)
  - **Critical**: Yes - for observability

- [ ] **MON-002**: Critical alerts configured
  - **Alert Count**: 6+ SEV1 alert rules
  - **Verification**: `grep -c "severity: critical" /etc/prometheus/rules/vault.yml`
  - **Expected**: SEV1 alerts for: cluster down, disk full, cert expiry, auth failures
  - **Critical**: Yes - incident detection

- [ ] **MON-003**: Log aggregation working
  - **Logs Received**: Vault audit logs in Splunk/ELK
  - **Verification**: Search for vault events: `index=vault sourcetype=vault_audit`
  - **Expected**: Logs present, indexed, searchable
  - **Critical**: No - but important for compliance

### Health Monitoring

- [ ] **HLTH-001**: Health check endpoint responsive
  - **Endpoint**: https://vault:8200/v1/sys/health
  - **Verification**: `curl -k https://localhost:8200/v1/sys/health | jq .`
  - **Expected**: JSON response with status, sealed, initialized fields

- [ ] **HLTH-002**: Health check detects failures
  - **Test**: Stop vault service, check health endpoint
  - **Verification**: Health endpoint returns 503 (sealed/error state)
  - **Expected**: Monitoring alerted within 60 seconds

---

## Security Validation

### Authentication & Authorization

- [ ] **SEC-AUTH-001**: Authentication required & enforced
  - **Test**: `curl -k https://vault:8200/v1/secret/data/test` (no token)
  - **Expected**: 401 Unauthorized
  - **Verification**: Request denied, error message shown

- [ ] **SEC-AUTH-002**: Valid credentials accepted, invalid denied
  - **Test**: Try valid token, then invalid token
  - **Expected**: Valid: 200 success, Invalid: 403 forbidden
  - **Verification**: Both cases verified

- [ ] **SEC-AUTH-003**: LDAP authentication working (if enabled)
  - **Test**: `vault login -method=ldap username=testuser`
  - **Expected**: Successful authentication, token issued
  - **Verification**: `vault token lookup` shows LDAP auth method

- [ ] **SEC-AUTH-004**: Token expiration enforced
  - **Test**: Create token with 1 hour TTL, wait for expiry
  - **Expected**: Expired token denied
  - **Verification**: 403 Forbidden after TTL expires

- [ ] **SEC-AUTH-005**: Session management working
  - **Test**: Logout via `vault logout`
  - **Expected**: Token invalidated
  - **Verification**: Subsequent requests denied

### Encryption

- [ ] **SEC-ENC-001**: Data encrypted in transit (TLS)
  - **Test**: Network packet capture: `tcpdump -i eth0 port 8200`
  - **Expected**: TLS handshake, encrypted payload
  - **Verification**: Cannot read plaintext secrets in packets
  - **Cert**: TLS 1.2+, SHA256+ certificate

- [ ] **SEC-ENC-002**: Data encrypted at rest
  - **Test**: Inspect storage backend (database/S3)
  - **Expected**: Secret data appears as encrypted blobs, not plaintext
  - **Verification**: Cannot read plaintext values from storage

- [ ] **SEC-ENC-003**: Certificate validation working
  - **Test**: Connect with invalid certificate: `curl -k --cacert /dev/null https://vault:8200/v1/sys/health`
  - **Expected**: Certificate validation error (if not using -k flag)
  - **Verification**: `curl https://vault:8200/...` (without -k) works only with valid cert

- [ ] **SEC-ENC-004**: Supported TLS versions only (1.2+)
  - **Test**: `openssl s_client -tls1_0 -connect vault:8200` should fail
  - **Expected**: TLS 1.0/1.1 connections rejected
  - **Verification**: Only TLS 1.2+ connections accepted

### Access Control

- [ ] **SEC-AC-001**: RBAC enforced
  - **Test**: User with `developer` role tries admin operation
  - **Expected**: Operation denied with 403 Forbidden
  - **Verification**: Audit log shows denial

- [ ] **SEC-AC-002**: Least privilege enforced
  - **Test**: Review policies for each role
  - **Expected**: Each role has minimal necessary permissions
  - **Verification**: No overly broad wildcard paths

- [ ] **SEC-AC-003**: Service account permissions restricted
  - **Test**: Service account token can read assigned secrets only
  - **Expected**: Can read /secret/docker/registry, cannot read /secret/admin/
  - **Verification**: Read succeeds for allowed paths, denied for others

- [ ] **SEC-AC-004**: API key rotation possible
  - **Test**: Generate new token for service account
  - **Expected**: New token issued, old token can be revoked
  - **Verification**: Old token denied after revocation

### Audit Logging

- [ ] **SEC-LOG-001**: All changes logged
  - **Test**: Make configuration change, check audit log
  - **Expected**: Change logged with who/what/when
  - **Format**: JSON entries with timestamp, auth, operation, path

- [ ] **SEC-LOG-002**: Logs cannot be modified
  - **Test**: Attempt to delete or edit audit log entry
  - **Expected**: Deletion denied or edit detected
  - **Verification**: Write-once storage or integrity checking active

- [ ] **SEC-LOG-003**: Sensitive data not logged
  - **Test**: Review audit logs for passwords/API keys
  - **Expected**: No plaintext sensitive data in logs
  - **Verification**: Secrets appear as redacted or encrypted

- [ ] **SEC-LOG-004**: Audit log retention meets compliance
  - **Test**: Check logs from 90 days ago
  - **Expected**: Logs available and complete
  - **Verification**: 1+ year retention implemented

---

## Compliance Validation

### Standards Compliance

- [ ] **COMP-SOC2**: SOC2 Type II controls in place
  - **Standard**: SOC2 Type II
  - **Requirement**: Access control, change management, audit trails
  - **Verification**: 
    - [ ] Vault restricts access to authorized users
    - [ ] All changes logged
    - [ ] Logs retained 1+ year
    - [ ] Quarterly access reviews performed
  - **Evidence**: Documented in `/opt/vault/compliance/soc2.md`

- [ ] **COMP-ISO27001**: ISO 27001 information security controls
  - **Standard**: ISO 27001
  - **Requirement**: Encryption, access control, asset management
  - **Verification**:
    - [ ] Data encrypted at rest and in transit
    - [ ] Access controls implemented
    - [ ] Keys managed securely
    - [ ] Backup/DR procedures in place
  - **Evidence**: Documented in compliance binder

- [ ] **COMP-PCI-DSS**: PCI-DSS requirements (if handling payment cards)
  - **Standard**: PCI-DSS v3.2.1
  - **Requirement**: Secure storage and transmission of credentials
  - **Verification**: Not applicable unless handling card data
  - **Evidence**: [Path to documentation]

### Data Handling

- [ ] **COMP-DATA-001**: Data retention policy enforced
  - **Policy**: Keep secrets in vault indefinitely, audit logs 1+ year
  - **Test**: Query for deleted secrets, check retention
  - **Expected**: Secrets deleted per request, audit logs retained
  - **Critical**: Yes - compliance requirement

- [ ] **COMP-DATA-002**: Data privacy controls
  - **Control**: No PII, PHI, or payment card data stored in vault
  - **Verification**: Policy prohibits PII in secrets, random checks
  - **Expected**: Vault contains only application credentials/keys
  - **Critical**: Yes - privacy requirement

---

## Disaster Recovery Validation

### Backup & Recovery

- [ ] **DR-BACKUP-001**: Backups created successfully
  - **Frequency**: Daily at 02:00 UTC
  - **Verification**: Check backup directory: `ls -lh /opt/vault/backups/ | head -5`
  - **Expected**: Multiple backup files present, daily pattern visible
  - **Critical**: Yes - recovery foundation

- [ ] **DR-BACKUP-002**: Backups verified (not corrupted)
  - **Test**: Restore backup to test system (offline)
  - **Expected**: Restore succeeds, vault data intact
  - **Time**: Restore completes in < 5 minutes
  - **Critical**: Yes - ensures backups usable

- [ ] **DR-BACKUP-003**: Backup encryption working
  - **Test**: Inspect backup file
  - **Expected**: File encrypted (binary data, not readable plaintext)
  - **Verification**: Cannot read secrets from backup file directly
  - **Critical**: Yes - security requirement

- [ ] **DR-BACKUP-004**: Backup retention policy enforced
  - **Policy**: Keep 30 daily backups + 1 yearly snapshot
  - **Verification**: Check backup count: `ls /opt/vault/backups/ | wc -l`
  - **Expected**: ~30 backup files, yearly archive separate
  - **Critical**: Yes - operational requirement

### Recovery Procedures

- [ ] **DR-RECOVERY-001**: Recovery procedure documented
  - **Document**: `/opt/vault/docs/recovery-runbook.md`
  - **Verification**: Runbook exists and is current (updated within 90 days)
  - **Expected**: Step-by-step recovery process, clear instructions
  - **Critical**: Yes - operational requirement

- [ ] **DR-RECOVERY-002**: Recovery procedure tested
  - **Test Date**: [YYYY-MM-DD]
  - **Tester**: [Name/Title]
  - **Test Scenario**: Complete cluster failure, restore from backup
  - **Result**: ✅ Successful / ❌ Failed
  - **Recovery Time**: [Actual time to full recovery]
  - **Issues Found**: [List any issues discovered]
  - **Critical**: Yes - validates capability

- [ ] **DR-RECOVERY-003**: RTO/RPO requirements met
  - **RTO Requirement**: 15 minutes (recover cluster)
  - **RPO Requirement**: 1 day (daily backups)
  - **Verified**: Recovery test completed within RTO, latest backup not > 24 hours old
  - **Critical**: Yes - business requirement

- [ ] **DR-RECOVERY-004**: Escrow keys distributed and tested
  - **Escrow Shares**: 5 total, 3 required to unseal
  - **Custodians**: [List 5+ named individuals/teams]
  - **Distribution**: Each holds 1 share, physically secured
  - **Test**: Recovery procedure tested using escrow shares
  - **Expected**: All 3 shares combine to unseal vault
  - **Critical**: Yes - security requirement

---

## Constraints Verification

- [ ] **CONST-001**: Secret lease TTL minimum 1 hour enforced
  - **Test**: Attempt to create secret with 30 minute TTL
  - **Expected**: Rejected or forced to minimum

- [ ] **CONST-002**: Secret size limit 1 MB enforced
  - **Test**: Attempt to store 2 MB secret
  - **Expected**: Rejected with error

- [ ] **CONST-003**: Key rotation minimum quarterly scheduled
  - **Test**: Review rotation schedule
  - **Expected**: Rotation jobs scheduled for at least quarterly cadence

- [ ] **CONST-004**: Audit log retention policy 3 years minimum
  - **Test**: Check audit log configuration
  - **Expected**: Retention set to 3+ years

- [ ] **CONST-005**: TLS certificate chain depth ≤ 4 levels
  - **Test**: Verify certificate chain: `openssl s_client -showcerts -connect vault:8200`
  - **Expected**: Chain shows 2-4 certificates max

---

## Sign-Off & Approval

### Pre-Deployment Approval

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Security Lead | _________________ | _________________ | ________ |
| Infrastructure Lead | _________________ | _________________ | ________ |
| Storage & Backup Owner | _________________ | _________________ | ________ |
| Compliance Officer | _________________ | _________________ | ________ |

**Comments/Issues**:
```
[Space for pre-deployment issues/approvals]
```

### Post-Deployment Validation

| Validation Stage | Status | Issues | Owner | Sign-off |
|---|---|---|---|---|
| Pre-Deployment | ✅/❌ | [List] | [Name] | [Signature] |
| Installation | ✅/❌ | [List] | [Name] | [Signature] |
| Skill Validation | ✅/❌ | [List] | [Name] | [Signature] |
| Integration | ✅/❌ | [List] | [Name] | [Signature] |
| Security | ✅/❌ | [List] | [Name] | [Signature] |
| Compliance | ✅/❌ | [List] | [Name] | [Signature] |
| DR & Backup | ✅/❌ | [List] | [Name] | [Signature] |

### Final Sign-Off

**Overall Status**: 🟢 Ready for Production / 🟡 Conditional Approval / 🔴 Issues Blocking Deployment

**Approved By**: _________________ (Security Lead)  
**Date**: _________________ 

**Phase 1 can proceed when**:
- [ ] All validation items passed or documented exception
- [ ] All sign-offs obtained
- [ ] Critical issues resolved
- [ ] Recovery procedure tested
- [ ] Team training completed

---

**Document Status**: Ready for Phase 1 deployment validation  
**Next Steps**:
1. Schedule validation kickoff meeting
2. Assign validation owners per section
3. Execute validation checklist items
4. Document any issues/exceptions
5. Obtain sign-offs
6. Proceed to Phase 1 Week 2 (Security & Secrets Agent deployment)
