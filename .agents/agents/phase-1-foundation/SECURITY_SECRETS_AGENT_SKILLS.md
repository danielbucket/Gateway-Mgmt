# Security & Secrets Agent Skills

**Status**: 🟡 TODO (Phase 1, Week 2-3)  
**Phase**: Phase 1 - Foundation  
**Timeline**: Weeks 2-3 of Phase 1  
**Owner**: Security & Infrastructure Team  
**Last Updated**: 2026-09-16

---

## Overview

The Security & Secrets Agent is responsible for all cryptographic material, credential management, access control policies, and security compliance across the gateway management ecosystem. This agent maintains the security posture of all infrastructure, services, and operations through secure secret storage, key rotation, access control enforcement, and comprehensive audit logging.

### Core Responsibilities

- **Secret Management**: Centralized vault for passwords, API keys, tokens, and credentials
- **Encryption Key Management**: Generation, rotation, storage, and lifecycle management of cryptographic keys
- **SSH Key Management**: Public/private key pair generation, distribution, and access control
- **Certificate Management**: TLS/SSL certificates, certificate signing requests, renewal automation
- **Access Control Policies**: RBAC definition, enforcement, and audit trails
- **Compliance & Audit Logging**: Security event logging, compliance reporting, audit trails
- **Security Incident Response**: Credential compromise response, key rotation, access revocation
- **Integration Security**: Secure communication protocols, mutual TLS, API security

### Integration Points

- **Upstream Dependencies**: Storage & Backup Agent (Week 1-2) - for secure backup of secrets vault
- **Downstream Integrations**: All 22 other agents (use secrets for authentication, encryption)
- **External Integrations**: HashiCorp Vault (or similar), Certificate Authority, SIEM system, HSM (optional)

---

## Skills Matrix

Total Skills: 6 | Validation Items: ~18 | Constraints: ~15

| # | Skill Name | Description | Status | Difficulty |
|---|---------|-------------|--------|------------|
| 1 | Secret Management & Vault Setup | Centralized secret storage, secret types, vault initialization | 🟡 | High |
| 2 | Encryption Key Management | Key generation, storage, rotation, versioning, HSM integration | 🟡 | High |
| 3 | SSH Key & Certificate Management | Key pair generation, distribution, access control, lifecycle | 🟡 | Medium |
| 4 | Access Control Policies (RBAC) | Role definition, permission assignment, policy enforcement | 🟡 | Medium |
| 5 | Compliance & Audit Logging | Security event logging, compliance tracking, audit reports | 🟡 | Medium |
| 6 | Security Incident Response | Credential compromise handling, emergency key rotation, access revocation | 🟡 | High |

### Skill Categories

**Core Security Infrastructure** (Skills #1-2)
- Skill 1: Secret Management & Vault Setup - Foundation for all credential security
- Skill 2: Encryption Key Management - Cryptographic material lifecycle

**Access & Authentication** (Skills #3-4)
- Skill 3: SSH Key & Certificate Management - User and service authentication
- Skill 4: Access Control Policies - Authorization and permission enforcement

**Compliance & Operations** (Skills #5-6)
- Skill 5: Compliance & Audit Logging - Regulatory compliance and forensics
- Skill 6: Security Incident Response - Incident handling and remediation

---

## Detailed Skill Descriptions

### Skill 1: Secret Management & Vault Setup

**Purpose**: Provide centralized, secure storage for all sensitive credentials including passwords, API keys, database credentials, and authentication tokens. Enable fine-grained access control and audit logging for all secret access.

**Key Procedures**:

1. **Vault Infrastructure Setup**
   - Deploy HashiCorp Vault (or equivalent) with HA and clustering
   - Configure persistent storage backend (encrypted)
   - Enable audit logging for all secret operations
   - Set up backup and disaster recovery

2. **Secret Types & Storage**
   - Database credentials (username, password, connection strings)
   - API keys and tokens (external service integration)
   - SSH keys (service-to-service authentication)
   - TLS certificates and private keys
   - Application configuration (secrets only, non-secrets go to config management)
   - Encryption keys (wrapped by master key)

3. **Secret Retrieval & Injection**
   - Application integration (Vault agent, SDK)
   - Environment variable injection
   - File-based secret delivery
   - Dynamic secret generation (database credentials, API tokens)
   - Automatic renewal before expiry

4. **Secret Lifecycle**
   - Secret creation and initial storage
   - Regular rotation policy enforcement
   - Access logging and audit trail
   - Expiration and automatic cleanup
   - Secure deletion (cryptographic erasure)

**Validation Items**:
- [ ] Vault cluster deployed and operational (all nodes healthy)
- [ ] Persistent storage encrypted and accessible
- [ ] Audit logging enabled and retained for 1+ year
- [ ] High availability verified (failover tested)
- [ ] Backup created and recovery tested
- [ ] Application integration verified (secrets retrieved correctly)
- [ ] Secret rotation policy defined and tested
- [ ] Unauthorized access attempts logged and alerted

**Common Issues & Troubleshooting**:
- **Issue**: Vault cluster member unreachable
  - **Cause**: Network connectivity, member down, Raft consensus lost
  - **Solution**: Check network, restart member, check Raft logs, consider cluster rebuild
- **Issue**: Application cannot retrieve secrets
  - **Cause**: Authentication token expired/invalid, policy missing, network issue
  - **Solution**: Verify auth token, check policy permissions, test network connectivity
- **Issue**: Secret rotation fails
  - **Cause**: Dynamic secret backend down, policy too restrictive, resource limits
  - **Solution**: Check backend status, verify policy, increase resource allocation

**Related Skills**: Skill 2 (encryption keys), Skill 6 (incident response)

---

### Skill 2: Encryption Key Management

**Purpose**: Generate, store, rotate, and manage cryptographic keys used for encryption at rest and in transit. Ensure keys are protected at the highest level and rotated on schedule.

**Key Procedures**:

1. **Key Generation & Storage**
   - Generate strong cryptographic keys (RSA 4096, AES-256, ECDSA-P256+)
   - Store keys in vault with master key encryption (envelope encryption)
   - Optional: HSM integration for highest security tier keys
   - Key metadata tracking (creation date, algorithm, strength, purpose)

2. **Key Hierarchy & Wrapping**
   - Master Key (stored in HSM or Vault, never exported)
   - Data Encryption Keys (DEK) wrapped by master key
   - Root CA key (isolated, strictly controlled access)
   - Application keys (encrypted with DEK)

3. **Key Rotation Policy**
   - Define rotation schedule per key type (quarterly default for active keys)
   - Implement key versioning (old keys retained for decryption)
   - Test key rotation without application downtime
   - Communicate rotation schedule to dependent services
   - Verify all data re-encryption (if required)

4. **Key Recovery & Escrow**
   - Escrow shares for disaster recovery (Shamir's Secret Sharing)
   - Secure distribution to key custodians (geographically distributed)
   - Escrow verification procedures
   - Recovery procedure testing

**Validation Items**:
- [ ] Master key generated and stored securely
- [ ] Key hierarchy documented and verified
- [ ] HSM integration operational (if applicable)
- [ ] Key rotation policy defined and scheduled
- [ ] Key versioning enabled and tested
- [ ] Escrow shares generated and secured
- [ ] Key recovery procedure tested and documented
- [ ] Audit logs show all key operations

**Common Issues & Troubleshooting**:
- **Issue**: HSM unreachable
  - **Cause**: Network, HSM offline, authentication failure
  - **Solution**: Test network connectivity, check HSM status, verify credentials
- **Issue**: Key rotation blocked
  - **Cause**: Resource locked, policy preventing rotation, dependent service not updated
  - **Solution**: Check locks, review policy, notify dependent services before rotation
- **Issue**: Corrupted escrow share
  - **Cause**: Storage degradation, access error, share loss
  - **Solution**: Regenerate escrow shares, redistribute to custodians, test recovery

**Related Skills**: Skill 1 (secret management), Skill 3 (certificates)

---

### Skill 3: SSH Key & Certificate Management

**Purpose**: Generate, distribute, and manage SSH key pairs and X.509 certificates for authentication and secure communication between systems, services, and users.

**Key Procedures**:

1. **SSH Key Management**
   - Generate RSA 4096 or ED25519 key pairs
   - Central repository for public keys (authorized_keys distribution)
   - Private key storage in vault with appropriate access controls
   - Forced key rotation on schedule (quarterly for active keys)
   - Audit logging of key usage (SSH session recording optional)

2. **Certificate Lifecycle**
   - Request certificate from CA (CSR generation)
   - Certificate validation and signing
   - Certificate storage and distribution
   - Certificate expiration monitoring
   - Automatic renewal before expiration
   - Revocation (CRL/OCSP if needed)

3. **TLS Certificate Management for Services**
   - Service certificate generation (domain validation)
   - Wildcard certificate alternatives
   - Certificate pinning for critical services
   - HSTS header enforcement
   - Certificate transparency logging

4. **User Authentication Certificates**
   - Client certificate generation for mutual TLS
   - Certificate-based authentication in APIs
   - Audit logging of certificate-based access
   - Revocation procedures for compromised certs

**Validation Items**:
- [ ] SSH key pairs generated and stored securely
- [ ] Public key distribution mechanism working
- [ ] Private key access restricted to authorized services
- [ ] Certificate auto-renewal operational (14 days before expiry)
- [ ] Certificate chain validation working
- [ ] Expired certificates identified and renewed
- [ ] Revocation list current and distributed
- [ ] Certificate usage audit trail enabled

**Common Issues & Troubleshooting**:
- **Issue**: SSH key authentication fails
  - **Cause**: Key mismatch, permission denied on authorized_keys, SSH config issue
  - **Solution**: Verify key pair, check authorized_keys, review SSH config
- **Issue**: Certificate validation fails
  - **Cause**: Expired certificate, chain incomplete, clock skew
  - **Solution**: Check expiration, verify chain, sync system time
- **Issue**: Certificate renewal fails
  - **Cause**: ACME server unreachable, DNS validation failure, rate limiting
  - **Solution**: Test ACME connectivity, verify DNS, check rate limits

**Related Skills**: Skill 1 (secret storage), Skill 2 (encryption keys), Skill 4 (access control)

---

### Skill 4: Access Control Policies (RBAC)

**Purpose**: Define and enforce fine-grained Role-Based Access Control across all agents and services. Ensure least-privilege access, proper audit trails, and compliance with security policies.

**Key Procedures**:

1. **Role Definition**
   - Identify all roles needed (Admin, Operator, Developer, Viewer, Service Account)
   - Define granular permissions per role (secret read, key rotate, audit log view)
   - Document role hierarchy and inheritance
   - Create test and production role variants
   - Version and track role definitions

2. **Permission Assignment**
   - Map users/services to roles
   - Service account creation with minimal privileges
   - Temporary elevated access with audit trail (break-glass procedures)
   - Approval workflow for high-privilege roles
   - Regular access review and cleanup

3. **Policy Enforcement**
   - Vault policy enforcement (per path, per operation)
   - Kubernetes RBAC integration (if applicable)
   - API authentication and authorization
   - SSH command restriction (if using certificates)
   - Network ACLs for administrative access

4. **Access Audit & Review**
   - Quarterly access review (all roles and assignments)
   - Manager sign-off on access levels
   - Removal of inactive users/services
   - Off-boarding procedures with access revocation
   - Compliance reporting (who has what access)

**Validation Items**:
- [ ] All roles defined and documented
- [ ] Principle of least privilege verified
- [ ] Permission assignments auditable and logged
- [ ] Service accounts with minimal access created
- [ ] Break-glass procedure documented and tested
- [ ] Access review process established
- [ ] Unauthorized access attempts detected and alerted
- [ ] Compliance dashboard showing current access state

**Common Issues & Troubleshooting**:
- **Issue**: User denied access to needed secret
  - **Cause**: Missing role, insufficient permissions, policy mismatch
  - **Solution**: Review user role, add permission to policy, test access
- **Issue**: Service uses expired token
  - **Cause**: Token TTL too short, service not refreshing
  - **Solution**: Increase token TTL, implement token refresh in service
- **Issue**: Leaked service account credentials
  - **Cause**: Accidental commit to repo, overly permissive access
  - **Solution**: Revoke credentials, rotate, audit access, implement secret scanning

**Related Skills**: Skill 1 (vault setup), Skill 5 (audit logging)

---

### Skill 5: Compliance & Audit Logging

**Purpose**: Maintain comprehensive audit trails of all security-relevant operations, demonstrate compliance with regulatory requirements (SOC2, ISO27001, HIPAA, PCI-DSS), and enable forensic investigation of security events.

**Key Procedures**:

1. **Audit Log Collection**
   - Vault audit logs (all secret access, policy changes)
   - SSH access logs (authentication, commands executed)
   - Certificate operations (generation, renewal, revocation)
   - Access control changes (role assignments, policy updates)
   - Key rotation events (including pre/post state)
   - Encryption/decryption operations (optional, high-volume)

2. **Audit Log Storage & Retention**
   - Centralized logging system (ELK stack, Splunk, etc.)
   - Immutable log storage (append-only, cryptographically verified)
   - Retention policy (1 year minimum, 3+ years recommended)
   - Log encryption at rest
   - Regular backup and recovery testing

3. **Compliance Reporting**
   - SOC2 Type II reports (access control, change management)
   - ISO27001 evidence (information security controls)
   - Regulatory audit requests (PCI-DSS, HIPAA, etc.)
   - Internal compliance dashboard
   - Monthly security posture reporting

4. **Forensics & Investigation**
   - Timeline reconstruction from audit logs
   - Identify who accessed what when
   - Detect unusual patterns (after-hours access, bulk exports)
   - Incident investigation procedures
   - Root cause analysis documentation

**Validation Items**:
- [ ] Audit logging enabled for all security operations
- [ ] Logs immutable and cryptographically verified
- [ ] Log retention policy enforced
- [ ] Centralized logging operational with redundancy
- [ ] Compliance reports generated automatically
- [ ] Log search/query capabilities working
- [ ] Security events detected and alerted
- [ ] Audit log integrity verified

**Common Issues & Troubleshooting**:
- **Issue**: Audit logs missing
  - **Cause**: Logging disabled, log rotation overflow, forwarding failure
  - **Solution**: Enable logging, check rotation, verify log forwarding
- **Issue**: Compliance gap identified
  - **Cause**: Policy not enforced, exception not documented, control failure
  - **Solution**: Implement control, document exception, add compensating control
- **Issue**: Cannot find event in audit trail
  - **Cause**: Incorrect time filter, log rotation, query syntax error
  - **Solution**: Expand time range, check log retention, verify query syntax

**Related Skills**: Skill 4 (access control), Skill 6 (incident response)

---

### Skill 6: Security Incident Response

**Purpose**: Respond rapidly to security incidents involving compromised credentials, leaked secrets, unauthorized access, or key compromise. Minimize impact and restore security posture.

**Key Procedures**:

1. **Incident Detection & Triage**
   - Detection methods: audit logs, alerts, user reports
   - Severity assessment (SEV1 = immediate threat, SEV2 = urgent, SEV3 = investigate)
   - Initial containment (disable account, revoke token, change password)
   - Evidence preservation (log collection, snapshot state)
   - Incident classification (credential leak, unauthorized access, key compromise)

2. **Credential Compromise Response**
   - Revoke all tokens/credentials for affected user/service
   - Force password/key reset on next login
   - Audit all access by compromised credential
   - Revoke any sessions/API tokens created by compromised account
   - Notify dependent services of credential rotation
   - Update password managers and documentation

3. **Key Compromise Response**
   - Immediately revoke compromised key version
   - Rotate key to new version
   - Decrypt all data encrypted with compromised key (if practical)
   - Re-encrypt with new key
   - Audit all decryption events by compromised key
   - Notify all services of key rotation
   - Document root cause and prevention measures

4. **Unauthorized Access Response**
   - Determine access scope (what was accessed)
   - Revoke compromised credentials/certificates
   - Review audit trail for lateral movement
   - Force all affected services to re-authenticate
   - Apply additional monitoring to affected systems
   - Consider full credential/key rotation if scope unknown

5. **Post-Incident Actions**
   - Document incident details and timeline
   - Root cause analysis (how was it compromised?)
   - Prevention measures (what will prevent recurrence?)
   - Implement preventive measures
   - Post-incident review (1-2 weeks after incident)
   - Update incident response procedures based on lessons learned

**Validation Items**:
- [ ] Incident response procedures documented and tested
- [ ] Alert thresholds set for suspicious activity
- [ ] Incident communication plan established
- [ ] Credential revocation procedures working
- [ ] Key rotation under incident stress tested
- [ ] Audit trail complete for incident investigation
- [ ] Post-incident review completed
- [ ] Preventive measures implemented

**Common Issues & Troubleshooting**:
- **Issue**: Cannot determine extent of compromise
  - **Cause**: Incomplete audit logs, time-delay in detection
  - **Solution**: Analyze all available logs, interview users, check backup snapshots
- **Issue**: Service fails after emergency credential rotation
  - **Cause**: Service not updated with new credentials, configuration mismatch
  - **Solution**: Manually update service config, test connectivity, restart service
- **Issue**: Rotated key doesn't work for existing encrypted data
  - **Cause**: Data encrypted with old key, rotation incomplete
  - **Solution**: Use old key version for existing data, update application for new key

**Related Skills**: Skill 1 (vault operations), Skill 2 (key management), Skill 5 (audit logs)

---

## Validation Checklist

✅ **Comprehensive Validation** (~18 items total):

### Pre-Deployment
- [ ] Infrastructure requirements defined (CPU, memory, storage for vault)
- [ ] Network connectivity verified (clients to vault, vault to storage)
- [ ] Storage backend available and tested (encrypted, HA-capable)
- [ ] CA/PKI infrastructure available (internal or external)

### Vault Deployment & Configuration
- [ ] Vault cluster deployed (all nodes starting clean)
- [ ] Persistent storage backend configured and verified
- [ ] Audit logging enabled and tested
- [ ] High availability verified (at least 3 nodes for Raft)
- [ ] Initial secrets loaded into vault (db creds, API keys)
- [ ] Application integration tested (services retrieve secrets successfully)

### Security Configuration
- [ ] RBAC policies configured per agent/service (least privilege)
- [ ] Encryption keys generated and stored in HSM or vault
- [ ] SSH key pairs generated for all service accounts
- [ ] TLS certificates generated for service-to-service communication

### Operational Verification
- [ ] Backup of vault data created and restoration tested
- [ ] Secret rotation working (tested with non-critical secret)
- [ ] Key rotation procedure documented and simulated
- [ ] Audit logs retained and searchable
- [ ] Incident response procedures tested (credential revocation)

### Compliance & Sign-off
- [ ] Compliance checklist completed (SOC2, regulatory requirements)
- [ ] Security review completed by security team
- [ ] Documentation complete and accessible
- [ ] Team training completed on vault operations
- [ ] Sign-off obtained from Storage & Backup Agent owner (upstream dependency)

---

## Constraints & Limits

⚠️ **Critical Constraints** (~15 total):

| Constraint | Value | Reason | Mitigation |
|-----------|-------|--------|-----------|
| Secret Lease TTL (min) | 1 hour | Limit token lifetime for security | Refresh tokens before expiry |
| Secret Size (max) | 1 MB | Vault storage performance | Split large configs into multiple secrets |
| Key Rotation Frequency (min) | Quarterly | Balance security vs. operational load | Schedule maintenance windows |
| Vault Storage Replication | ≤ 3 regions | Latency and consistency issues | Document RPO/RTO per region |
| Number of Concurrent Requests | 500/sec | Vault performance ceiling | Implement request queuing/throttling |
| HSM Transaction Throughput | 1000 ops/min | HSM hardware limitation | Cache results where safe |
| Audit Log Retention | 3 years max | Compliance storage requirements | Archive older logs to cold storage |
| Secret Access Rate Limiting | 100/sec per IP | DDoS protection | Whitelist trusted services |
| TLS Certificate Chain Depth | ≤ 4 levels | Certificate validation complexity | Flatten chains where possible |
| Key Escrow Shares | ≥ 3 total | Shamir's Secret Sharing minimum | Distribute to 3+ trusted custodians |
| Backup Encryption | AES-256 | Industry standard minimum | Use same encryption as vault storage |
| Credential Rotation Time | ≤ 30 sec | Service downtime minimization | Test rotation under load |
| Administrator Access Tokens | 8-hour TTL | Balance convenience and security | Require re-authentication for sensitive ops |
| Audit Log Volume | ~100 MB/day | Typical load, high-access environments | Monitor log growth and adjust retention |
| Compliance Audit Frequency | Quarterly | Regulatory requirement | Schedule well in advance |

---

## Architecture & Design

### Deployment Model

**Primary Location**: Gateway node (24.204.72.65)  
**Backup Location**: SpaceBase node (24.204.72.66) - active standby  
**Network Requirements**: 
- Port 8200 (Vault API) - internal cluster communication
- Port 8201 (Raft) - cluster consensus
- Isolated network segment for administrative access
**Resource Requirements**: 
- CPU: 4 cores (minimum 2, recommended 4+)
- Memory: 8 GB (minimum 4 GB)
- Disk: 100 GB SSD (encrypted, on storage backend)
- Network: 1 Gbps redundant links

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    Security & Secrets Agent                 │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  HashiCorp Vault Cluster (HA)                         │  │
│  │  ┌──────────────────┐    ┌──────────────────┐        │  │
│  │  │  Vault Node 1    │    │  Vault Node 2    │        │  │
│  │  │  (Gateway)       │◄───│  (SpaceBase)     │        │  │
│  │  └────────┬─────────┘    └────────┬─────────┘        │  │
│  │           │ Raft Consensus       │                    │  │
│  │           └───────────┬──────────┘                    │  │
│  │                       │                                │  │
│  │            ┌──────────▼──────────┐                    │  │
│  │            │ Persistent Storage  │                    │  │
│  │            │ (Encrypted Backend) │                    │  │
│  │            └─────────────────────┘                    │  │
│  └───────────────────────────────────────────────────────┘  │
│                       │                                      │
│       ┌───────────────┼───────────────┐                     │
│       ▼               ▼               ▼                     │
│  ┌─────────────┐ ┌──────────┐ ┌──────────────┐            │
│  │Master Keys  │ │API Keys  │ │SSH Keys &    │            │
│  │(HSM if avl.)│ │Database  │ │Certificates  │            │
│  │             │ │Creds     │ │              │            │
│  └─────────────┘ └──────────┘ └──────────────┘            │
│                                                               │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Audit Logging System                                │  │
│  │  • Secret access events                              │  │
│  │  • Policy changes                                    │  │
│  │  • Authentication events                             │  │
│  │  → Centralized logging (Splunk/ELK)                  │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                               │
└─────────────────────────────────────────────────────────────┘
                           │
            ┌──────────────┼──────────────┐
            ▼              ▼              ▼
        [Applications] [Services]  [Administrators]
         (Retrieve    (Auth with   (Access vault
          secrets)    secrets)      CLI/UI)
```

### Data Flow Diagram

```
Application/Service
        │
        │ 1. Request secret
        ▼
    Vault API
        │
        ├─► 2a. Check auth token validity
        │
        ├─► 2b. Check RBAC policy
        │
        ├─► 2c. Audit log request
        │
        ▼
    Secret Storage
        │
        ├─► 3a. Decrypt with master key
        │
        ▼
    Return secret to application
        │
        ├─► 4. Application stores in memory/env var
        │
        └─► 5. Audit log: secret retrieved
```

---

## Integration Guide

### Upstream Dependencies

**Must Deploy First**:
- **Storage & Backup Agent** (Phase 1, Week 1-2)
  - Why needed: Vault data must be backed up with encryption and redundancy
  - Verification: Backup job runs successfully, recovery tested

**How to Verify Readiness**:
1. Storage & Backup Agent operational and backup-capable
2. Encrypted storage available for vault backups
3. Backup job scheduling working
4. Restore procedure tested and documented

### Downstream Integrations

**These Agents Depend on This One**:
- **All 22 other agents** - use credentials for authentication and service-to-service communication
- **Docker Agent** - retrieves registry credentials, service secrets
- **Network Agent** - SSH keys for administrative access
- **Prometheus Agent** - API keys for external integrations
- **All Phase 2+ agents** - authentication and encryption

**Integration Points**:

| Dependent Agent | Integration Type | Details |
|---|---|---|
| Docker Agent | REST API | Vault agent sidecar, secret injection into containers |
| Network Agent | SSH Keys | SSH key pairs for admin access |
| Prometheus Agent | API Keys | API tokens for external service integration |
| All Phase 2 agents | Auth tokens | Service tokens for API authentication |
| CI/CD Pipeline | Secrets | Deployment credentials and artifact signing keys |
| Logging Agent | Credentials | Database credentials, log forwarding auth |

### Cross-Domain Dependencies

| Domain | Agent | Integration |
|--------|-------|-------------|
| Infrastructure | Network Infrastructure Agent | SSH keys for administrative access |
| Infrastructure | Network Agent | Firewall rule credentials |
| Services | Docker Agent | Container registry credentials, service secrets |
| Services | Samba Agent | Share credentials and encryption keys |
| Services | WireGuard Agent | VPN encryption keys |
| Observability | Prometheus Agent | API keys for external scrape targets |
| Quality | Audit & Validation Agent | Audit log access credentials |

---

## Operations & Procedures

### Startup Procedure

**Pre-Startup Checks**:
- [ ] Vault binary present at `/opt/vault/bin/vault`
- [ ] Vault configuration file valid (JSON syntax correct)
- [ ] Storage backend reachable (database/S3/disk accessible)
- [ ] Network connectivity verified (port 8200, 8201 open)
- [ ] Systemd service file in place at `/etc/systemd/system/vault.service`

**Startup Steps**:
1. Verify no vault process already running: `ps aux | grep vault`
2. Start vault service: `sudo systemctl start vault`
3. Check service status: `sudo systemctl status vault`
4. Verify vault is initialized: `vault status`
5. If first node: Initialize vault (generates unseal keys)
6. Unseal vault with unseal keys: `vault operator unseal <key>`
7. Join additional nodes (run step 6 on each node)
8. Verify cluster status: `vault operator members`
9. Load initial secrets into vault (first run only)

**Post-Startup Validation**:
- [ ] Vault API responding: `curl http://localhost:8200/v1/sys/health`
- [ ] Authentication working: `vault login -method=ldap username=admin`
- [ ] Secret retrieval working: `vault read secret/data/test`
- [ ] Cluster status healthy: All 3+ nodes initialized and sealed
- [ ] Audit logging enabled: Check `/var/log/vault/audit.log`
- [ ] No startup errors in logs: `journalctl -u vault -n 50`

### Shutdown Procedure

**Pre-Shutdown Checks**:
- [ ] Verify no critical operations in progress
- [ ] Notify all service owners of planned maintenance
- [ ] Alert monitoring team (disable alerts during maintenance)
- [ ] Backup vault data: `vault operator raft snapshot save backup.snap`

**Shutdown Steps**:
1. Graceful seal if performing maintenance: `vault operator seal`
2. Stop vault service: `sudo systemctl stop vault`
3. Verify process stopped: `ps aux | grep vault` (no vault process)
4. Backup vault data files (if on local disk)
5. For planned restarts: Keep seal keys safe
6. For decommissioning: Securely destroy seal keys and backups

### Health Check Procedure

**Frequency**: Daily (automated) + weekly manual review

**Automated Checks** (run via cron):
```bash
#!/bin/bash
VAULT_ADDR="https://vault.internal:8200"
# Check health endpoint
curl -s "${VAULT_ADDR}/v1/sys/health" | grep -q "initialized"
# Check cluster members
vault operator members | grep -q "3 nodes"
# Check recent audit logs
tail -100 /var/log/vault/audit.log | grep -v "error" | wc -l
```

**Manual Health Checks** (weekly):
1. Check vault status: `vault status`
   - ✅ Sealed: false (should be unsealed)
   - ✅ Initialized: true
   - ✅ HA Enabled: true
   - ✅ HA Cluster: https://vault-1.internal:8201
   
2. Check cluster members: `vault operator members`
   - ✅ All 3+ nodes showing as active
   - ✅ No failed nodes
   
3. Test secret retrieval: `vault read secret/data/test-secret`
   - ✅ Returns valid secret
   
4. Review audit logs (last 24 hours): `vault audit list`
   - ✅ Logging active
   - ✅ No suspicious access patterns
   
5. Check storage backend health
   - ✅ Database responding
   - ✅ Disk space adequate (> 20% free)
   - ✅ No replication lag (if replicated)

**Success Criteria**:
- ✅ All cluster nodes healthy and responsive
- ✅ Secrets retrievable without delay (< 100ms)
- ✅ Audit logging active and current
- ✅ No errors in logs in last 24 hours
- ✅ Backup created within last 24 hours

### Update/Upgrade Procedure

**Update Frequency**: 
- Security patches: Immediate (within 24 hours)
- Feature releases: Quarterly
- Patch releases: As needed

**Pre-Update**:
- [ ] Backup vault data: `vault operator raft snapshot save backup-$(date +%Y%m%d).snap`
- [ ] Review release notes for breaking changes
- [ ] Notify all teams: Scheduled maintenance window
- [ ] Disable monitoring alerts: Prevent false positives during restart
- [ ] Prepare rollback plan: Have backup and previous version available

**Update Steps** (for each node, one at a time):
1. Download new vault binary: `wget https://releases.hashicorp.com/vault/X.Y.Z/vault_X.Y.Z_linux_amd64.zip`
2. Verify checksum: `sha256sum -c vault_X.Y.Z_SHA256SUMS`
3. Stop vault service: `sudo systemctl stop vault`
4. Backup current binary: `sudo cp /opt/vault/bin/vault /opt/vault/bin/vault-backup-X.Y.Z`
5. Extract new binary: `sudo unzip -o vault_X.Y.Z_linux_amd64.zip -d /opt/vault/bin/`
6. Verify new binary: `/opt/vault/bin/vault version`
7. Start vault service: `sudo systemctl start vault`
8. Verify node rejoins cluster: Wait 30-60 seconds
9. Check cluster status: `vault operator members`
10. Repeat for next node (wait for leadership transfer)

**Post-Update Validation**:
- [ ] All cluster nodes unsealed and active
- [ ] Secrets retrievable successfully
- [ ] Audit logs showing normal activity
- [ ] No error messages in logs
- [ ] Re-enable monitoring alerts
- [ ] Document update completion and any issues

---

## Troubleshooting Guide

### Vault Cluster Issues

**Symptom**: Vault API returning "503 Service Unavailable"

**Diagnostic Steps**:
1. Check vault service status: `sudo systemctl status vault`
2. Check vault logs: `journalctl -u vault -n 50`
3. Check cluster membership: `vault operator members` (from working node)
4. Check network connectivity: `ping -c 3 vault-node-2` (test node-to-node)
5. Check Raft consensus: `vault operator raft autopilot state` (if available)

**Common Causes & Solutions**:
- **Cause 1**: Node process crashed
  - Solution: Check logs for panic/error, restart service, verify startup checks
- **Cause 2**: Network partition between nodes
  - Solution: Test network connectivity, check firewall rules, verify DNS resolution
- **Cause 3**: Disk full on storage backend
  - Solution: Check disk space, clean up old data/logs, increase storage
- **Cause 4**: Raft consensus lost (even number of nodes)
  - Solution: Ensure odd number of nodes (3, 5, 7...), investigate node failures

**Escalation Path**: Contact Storage & Backup Agent owner if data loss possible

---

### Secret Retrieval Issues

**Symptom**: Application receiving "permission denied" when retrieving secret

**Diagnostic Steps**:
1. Verify auth token: `vault token lookup <token>`
2. Check token policies: Look for secret path in policies
3. Test manual retrieval: `vault read secret/data/<path> -token=<token>`
4. Review policy file: `vault policy read <policy-name>`
5. Check audit log: `tail -50 /var/log/vault/audit.log | grep <token>`

**Common Causes & Solutions**:
- **Cause 1**: RBAC policy missing permission for secret path
  - Solution: Add path to policy, update policy on vault, re-check access
- **Cause 2**: Token expired
  - Solution: Generate new token or increase TTL, update application config
- **Cause 3**: Policy uses wrong secret path (path=/secret/* vs path=/secret/data/*)
  - Solution: Review KV v1 vs v2 differences, update policy path matching

---

### Key Rotation Issues

**Symptom**: Key rotation fails with "cannot find key version"

**Diagnostic Steps**:
1. Check HSM connectivity (if used): Test HSM connection
2. Verify key exists: `vault read transit/keys/<keyname>`
3. Check key versions: `vault read transit/keys/<keyname>/rotate_configuration`
4. Review error logs: `journalctl -u vault | grep rotate`
5. Test with non-critical key first

**Common Causes & Solutions**:
- **Cause 1**: Key doesn't exist on HSM
  - Solution: Verify key name, regenerate key if needed, test with backup key
- **Cause 2**: HSM firmware limitation or bug
  - Solution: Update HSM firmware, contact HSM vendor support
- **Cause 3**: Data encrypted with key still in use
  - Solution: Allow more time before rotation, verify decryption still works

---

### Performance Issues

**Symptom**: Secret retrieval taking > 500ms, affecting application latency

**Diagnostic Steps**:
1. Monitor vault CPU and memory: `top -p <vault-pid>`
2. Check database latency: Measure query times
3. Check network latency: `ping -c 100 vault-node-2`
4. Review active connections: `vault token list` (count)
5. Check TLS handshake time: `openssl s_client -connect vault:8200`

**Common Causes & Solutions**:
- **Cause 1**: Database under load (connection pooling issue)
  - Solution: Increase connection pool size, add read replicas, optimize queries
- **Cause 2**: Network latency between vault and storage
  - Solution: Migrate to faster network, add caching layer
- **Cause 3**: TLS certificate validation expensive
  - Solution: Use hardware acceleration, consider token caching in applications

---

## Monitoring & Alerting

### Metrics to Monitor

| Metric | Target | Alert Threshold | Action |
|--------|--------|-----------------|--------|
| Vault API Response Time | < 100ms | > 500ms (SEV2) | Check database, scale vault |
| Cluster Members Healthy | 3 nodes | < 3 nodes (SEV1) | Investigate node failure, restart |
| Unseal Status | All unsealed | Any sealed (SEV1) | Emergency unseal procedure |
| Secret Access Success Rate | 99.9% | < 99% (SEV2) | Review recent changes |
| Storage Disk Usage | < 80% | > 90% (SEV2) | Plan expansion, archive old data |
| Audit Log Lag | 0 seconds | > 10 seconds (SEV3) | Check log ingestion, clear backlog |
| Key Rotation Status | On schedule | Overdue (SEV3) | Manually rotate, investigate failures |
| Authentication Failures | < 1% | > 5% (SEV2) | Check policies, test auth integration |

### Alert Rules

**SEV1 Alerts** (Critical - immediate response, page on-call):
- Vault cluster has < 3 healthy nodes
- All nodes sealed (cluster unavailable)
- Storage backend unreachable
- Unseal key lost (emergency seal detected)
- Audit logging failed for > 5 minutes
- Master key compromised (SEV0 - nuclear option)

**SEV2 Alerts** (High - respond within 1 hour):
- API response time > 500ms consistently
- Secret retrieval success rate < 99%
- Storage disk usage > 90%
- Key rotation missed deadline
- Authentication failures > 5%
- HSM unreachable (if applicable)

**SEV3 Alerts** (Medium - address within 1 business day):
- Audit log lag > 10 seconds
- Certificate expiring within 7 days
- Unused secrets not rotated in 180 days
- Policy syntax warnings
- Backup created > 24 hours ago

### Logging & Diagnostics

**Log Locations**:
- `/var/log/vault/audit.log` - All secret operations
- `journalctl -u vault` - Service logs and errors
- `/var/log/secure` - SSH access attempts
- Vault UI logs (if UI enabled) - HTTP requests

**Log Levels**:
- INFO: Secret reads/writes, policy changes, authentication events
- WARN: Failed authentications, policy errors, approaching limits
- ERROR: Vault crashes, storage errors, critical configuration issues

---

## Performance Characteristics

### Typical Performance

- Secret retrieval latency: 50-100ms (local network)
- Secret write latency: 100-200ms (includes Raft replication)
- Key rotation time: < 30 seconds per key
- Authentication success rate: 99.9%+
- Audit log latency: < 1 second behind operation

### Scalability

- Concurrent API requests: 1000+/sec (with cluster of 5 nodes)
- Maximum stored secrets: 100,000+ (depends on storage backend)
- Audit log capacity: 1GB+/day (with 3+ node cluster)

---

## Disaster Recovery

### Backup Strategy

- **Frequency**: Daily at 02:00 UTC
- **Method**: Raft snapshot (point-in-time backup)
- **Storage**: Encrypted backup to S3 + local copy
- **Retention**: 30 days rolling backups + 1 yearly snapshot
- **Testing**: Recovery tested monthly from production backup

### Recovery Procedure

1. Stop all vault nodes: `sudo systemctl stop vault`
2. Restore backup file: `cp backup-YYYYMMDD.snap /opt/vault/data/raft/`
3. Start vault: `sudo systemctl start vault`
4. Unseal with escrow keys: `vault operator unseal <key>`
5. Verify cluster status: `vault operator members`
6. Validate secret integrity: Spot-check critical secrets

### RTO/RPO

- **Recovery Time Objective (RTO)**: 15 minutes (restore from backup + unseal)
- **Recovery Point Objective (RPO)**: 1 day (daily backup cadence)

---

## Security & Compliance

### Access Controls

- Admin access: Limited to 3-5 security team members
- Service accounts: One per service, minimal permissions
- Operator access: Break-glass procedures with audit trail
- User access: Via LDAP/SAML federation

### Encryption Standards

- Data at rest: AES-256 (Vault default)
- Data in transit: TLS 1.2+ (mutual TLS for cluster)
- Key derivation: PBKDF2-SHA256 (token generation)
- Backup encryption: AES-256 (matching storage)

### Compliance Evidence

- SOC2 Type II: Secret access audit trails, change management
- ISO27001: Key management procedures, access control
- PCI-DSS: Encryption of sensitive data, access logging
- HIPAA: Audit trails, encryption, access controls

---

## Quick Reference & Examples

### Common Commands

```bash
# Initialize vault (first run only)
vault operator init -key-shares=5 -key-threshold=3

# Unseal vault
vault operator unseal <unseal-key-1>
vault operator unseal <unseal-key-2>
vault operator unseal <unseal-key-3>

# Read a secret
vault read secret/data/myapp/database

# Write a secret
vault write secret/data/myapp/database password="secret-password"

# Rotate a key
vault write -f transit/keys/mykey/rotate

# Generate SSH key pair
vault write -f ssh/keys/my-keypair key_type=rsa bits=4096

# List policies
vault policy list

# Enable LDAP auth
vault auth enable ldap
vault write auth/ldap/config url="ldap://ldap.example.com"

# Check status
vault status

# View cluster members
vault operator members
```

### Example Application Integration

```python
#!/usr/bin/env python3
import hvac
import os

# Create Vault client
client = hvac.Client(url='https://vault.internal:8200')

# Authenticate with service account
client.auth.kubernetes.login(
    role='my-app-role',
    jwt=open('/var/run/secrets/kubernetes.io/serviceaccount/token').read()
)

# Retrieve database credentials
secret = client.secrets.kv_v2_read_secret_version(
    path='database/prod'
)
db_password = secret['data']['data']['password']
db_username = secret['data']['data']['username']

# Connect to database with credentials
# ... application logic ...
```

---

## Team Contacts & On-Call

| Role | Name | On-Call Phone | Escalation |
|------|------|---------------|------------|
| Security Lead | [TBD] | [TBD] | [Manager name] |
| On-Call Engineer | [TBD] | [TBD] | Security Lead |
| Escalation Contact | [TBD] | [TBD] | [Manager] |

---

**Document Status**: Ready for Phase 1 deployment  
**Next Steps**: 
1. Review and approve by Security & Infrastructure team
2. Schedule Storage & Backup Agent deployment (Week 1)
3. Deploy Security & Secrets Agent (Weeks 2-3)
4. Validate and proceed to Phase 2
