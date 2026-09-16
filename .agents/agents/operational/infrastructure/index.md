# Operational Agents - Infrastructure Domain

**Location**: `agents/operational/infrastructure/`  
**Purpose**: Network topology, routing, IP allocation, and infrastructure connectivity  
**Status**: 🟢 DEPLOYED (2 agents)

---

## Agents in This Domain

| Agent | Skills | Validation | Constraints | Purpose | Links |
|-------|--------|-----------|------------|---------|-------|
| Network Infrastructure Agent | 7 | ~76 | ~25 | Single source of truth for topology, IPs, node allocation | [Skills](./NETWORK_INFRASTRUCTURE_AGENT_SKILLS.md) |
| Network Agent | 5 | ~20 | ~18 | Firewall, routing, network access control | [Skills](./NETWORK_AGENT_SKILLS.md) |

---

## Domain Overview

The Infrastructure domain handles all network-level operations:

- **Topology management** (nodes, IPs, routing)
- **IP allocation** (IPAM, reservations, assignments)
- **Network segmentation** (subnets, VLANs)
- **Firewall management** (rules, policies, access control)
- **Routing** (paths, failover, multi-site)
- **DNS coordination** (with Pi-hole Agent)

---

## Key Integrations

These agents are referenced by:
- **All agents** (topology authority)
- **Transmission Protocol Agent** (port & protocol routing)
- **Security & Secrets Agent** (network access policies)
- **Disaster Recovery Agent** (failover routing)
- **Docker Agent** (node networking)

---

## Network Topology

**Current Network**: 24.204.72.64/26 (public, 62 usable addresses)

| Node | IP | Purpose | Status |
|------|----|---------|----|
| Gateway | 24.204.72.65 | Docker Swarm Manager, Prometheus, Samba, Jumpbox, Pi-hole | 🟢 |
| SpaceBase | 24.204.72.66 | Docker Swarm Worker, Samba | 🟢 |
| Hyperdrive | 24.204.72.67 | WireGuard peer, Mesh node | 🟢 |
| Laboratory | 24.204.72.68 | WireGuard peer, Mesh node | 🟢 |
| Reserved | 24.204.72.69-126 | Future expansion (58 addresses) | ⚪ |

---

## Critical Dependencies

Both agents must be consulted for:
- Any infrastructure changes
- New service deployments
- Network scaling
- IP allocation
- Failover planning
- Multi-site coordination

---

## Quick Links

- [Network Infrastructure Agent Skills](./NETWORK_INFRASTRUCTURE_AGENT_SKILLS.md)
- [Network Agent Skills](./NETWORK_AGENT_SKILLS.md)
- [Master Index](../../AGENT_ECOSYSTEM_INDEX.md)
- [Phase 1 - Security & Secrets](../../phase-1-foundation/index.md) (depends on)
- [Phase 2 - Service Mesh](../../phase-2-observability/index.md) (depends on)
- [Phase 3 - Transmission Protocol](../../phase-3-operations/index.md) (depends on)

---

## Network Diagram

```
┌──────────────────────────────────────────────────────────┐
│  24.204.72.64/26 Network (Gateway Management)            │
├──────────────────────────────────────────────────────────┤
│                                                            │
│  Gateway (24.204.72.65) ← Docker Swarm Manager           │
│  ├─ Prometheus (monitoring)                              │
│  ├─ Samba (file sharing)                                 │
│  ├─ Jumpbox (admin access)                               │
│  ├─ Pi-hole (DNS filtering)                              │
│  └─ Network traffic hub                                  │
│                                                            │
│  SpaceBase (24.204.72.66) ← Docker Swarm Worker         │
│  ├─ Samba replica                                        │
│  └─ Service containers                                   │
│                                                            │
│  Hyperdrive (24.204.72.67) ← WireGuard Peer             │
│  ├─ VPN endpoint                                         │
│  └─ Mesh node                                            │
│                                                            │
│  Laboratory (24.204.72.68) ← WireGuard Peer             │
│  ├─ VPN endpoint                                         │
│  └─ Mesh node                                            │
│                                                            │
│  Future (24.204.72.69-126) ← Reserved (58 IPs)          │
│                                                            │
└──────────────────────────────────────────────────────────┘
```

---

**Last Updated**: September 16, 2026  
**Status**: Production Operational  
**Next Review**: Quarterly or when scaling beyond 62 node capacity
