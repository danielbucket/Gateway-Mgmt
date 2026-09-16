# Operational Agents - Services Domain

**Location**: `agents/operational/services/`  
**Purpose**: Docker containers, file sharing, VPN mesh, and service deployment  
**Status**: 🟢 DEPLOYED (3 agents)

---

## Agents in This Domain

| Agent | Skills | Validation | Constraints | Purpose | Links |
|-------|--------|-----------|------------|---------|-------|
| Docker Agent | 6 | ~20 | ~18 | Container orchestration, Swarm management, service deployment | [Skills](./DOCKER_AGENT_SKILLS.md) |
| Samba Agent | 7 | ~22 | ~20 | File sharing, SMB/CIFS protocol, multi-node shares | [Skills](./SAMBA_AGENT_SKILLS.md) |
| WireGuard Agent | 9 | ~26 | ~22 | VPN mesh, peer management, secure tunneling | [Skills](./WIREGUARD_AGENT_SKILLS.md) |

---

## Domain Overview

The Services domain handles all container and application-level services:

- **Docker Swarm** orchestration (manager, workers, services)
- **Container** lifecycle (deployment, updates, scaling)
- **File sharing** (SMB/CIFS, multi-node access)
- **VPN mesh** (peer-to-peer connections, mesh networking)
- **Service discovery** (container networking)
- **Port exposure** & protocol management

---

## Service Deployment Locations

### Gateway (24.204.72.65)
- Docker Swarm Manager
- Prometheus container
- Samba server (primary)
- Jumpbox container
- Pi-hole container

### SpaceBase (24.204.72.66)
- Docker Swarm Worker
- Samba replica
- Application containers

### Hyperdrive (24.204.72.67)
- WireGuard peer
- Mesh node
- Optional service containers

### Laboratory (24.204.72.68)
- WireGuard peer
- Mesh node
- Optional service containers

---

## Key Integrations

### Docker Agent depends on / integrates with:
- **Network Infrastructure Agent** (IP allocation, node topology)
- **Network Agent** (port exposure, firewall rules)
- **Security & Secrets Agent** (container secrets, credentials)
- **Storage & Backup Agent** (volume snapshots)
- **Prometheus Agent** (container metrics)

### Samba Agent depends on / integrates with:
- **Docker Agent** (container deployment)
- **Network Agent** (SMB port 445 exposure)
- **Security & Secrets Agent** (SMB passwords)
- **Storage & Backup Agent** (share backups)
- **Transmission Protocol Agent** (SMB protocol mgmt)

### WireGuard Agent depends on / integrates with:
- **Docker Agent** (optional peer containers)
- **Network Infrastructure Agent** (peer topology)
- **Network Agent** (UDP 51820 exposure)
- **Security & Secrets Agent** (key management, rotation)
- **Transmission Protocol Agent** (UDP protocol mgmt)

---

## Container Port Allocations

| Container | Port | Protocol | Purpose | Exposed | Links |
|-----------|------|----------|---------|---------|-------|
| Prometheus | 9090 | HTTP | Metrics collection | 🟢 | Network Agent |
| Samba | 445 | TCP | File sharing | 🟢 | Transmission Protocol |
| Samba | 139 | TCP | Legacy sharing | 🟢 | Transmission Protocol |
| Jumpbox | 22 | SSH | Admin access | Limited | Transmission Protocol |
| Pi-hole | 53 | DNS | Name resolution | 🟢 | Transmission Protocol |
| Pi-hole | 80 | HTTP | Admin dashboard | Internal | Security Agent |
| WireGuard Peers | 51820 | UDP | VPN | 🟢 | Transmission Protocol |
| Docker Swarm | 2377 | TCP | Manager API | Internal | Docker Agent |
| Docker Swarm | 7946 | TCP/UDP | Mesh gossip | Internal | Docker Agent |
| Docker Swarm | 4789 | UDP | Overlay network | Internal | Docker Agent |

---

## Quick Links

- [Docker Agent Skills](./DOCKER_AGENT_SKILLS.md)
- [Samba Agent Skills](./SAMBA_AGENT_SKILLS.md)
- [WireGuard Agent Skills](./WIREGUARD_AGENT_SKILLS.md)
- [Master Index](../../AGENT_ECOSYSTEM_INDEX.md)
- [Infrastructure Domain](../infrastructure/index.md) (depends on)
- [Observability Domain](../observability/index.md) (feeds into)
- [Phase 1 - Security](../../phase-1-foundation/index.md) (depends on)
- [Phase 2 - Jumpbox & Pi-hole](../../phase-2-observability/index.md) (runs in Docker)
- [Phase 3 - Transmission Protocol](../../phase-3-operations/index.md) (manages ports)
- [Phase 3 - CI/CD](../../phase-3-operations/index.md) (deploys containers)

---

## Service Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                  Docker Swarm Cluster                        │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  Manager Node (Gateway - 24.204.72.65)                       │
│  ├─ Prometheus (9090:HTTP)                                   │
│  ├─ Samba Primary (445:SMB, 139:legacy)                      │
│  ├─ Jumpbox (22:SSH)                                         │
│  ├─ Pi-hole (53:DNS, 80:HTTP-internal)                       │
│  └─ Swarm Manager (2377:TCP-internal)                        │
│                                                               │
│  Worker Node (SpaceBase - 24.204.72.66)                      │
│  ├─ Samba Replica (445:SMB, 139:legacy)                      │
│  └─ App Containers (dynamic ports)                           │
│                                                               │
│  Overlay Network (all containers)                            │
│  └─ Gossip (7946:TCP/UDP-internal)                           │
│  └─ Overlay (4789:UDP-internal)                              │
│                                                               │
│  WireGuard Mesh (external VPN)                               │
│  ├─ Peer 1 (Hyperdrive - 51820:UDP)                          │
│  ├─ Peer 2 (Laboratory - 51820:UDP)                          │
│  └─ Connections via Network Infrastructure                   │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

---

## Critical Operations

**Before scaling services**, consult:
1. **Docker Agent** - Service deployment procedures
2. **Network Infrastructure Agent** - IP allocation for new nodes
3. **Security & Secrets Agent** - Credential setup
4. **Transmission Protocol Agent** - Port availability & assignment

---

**Last Updated**: September 16, 2026  
**Status**: Production Operational  
**Next Review**: When deploying new services or scaling
