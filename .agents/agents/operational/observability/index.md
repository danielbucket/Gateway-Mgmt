# Operational Agents - Observability Domain

**Location**: `agents/operational/observability/`  
**Purpose**: Monitoring, metrics collection, alerting, and observability  
**Status**: 🟢 DEPLOYED (1 agent)

---

## Agents in This Domain

| Agent | Skills | Validation | Constraints | Purpose | Links |
|-------|--------|-----------|------------|---------|-------|
| Prometheus Agent | 6 | ~24 | ~20 | Metrics collection, alerting, time-series data, dashboards | [Skills](./PROMETHEUS_AGENT_SKILLS.md) |

---

## Domain Overview

The Observability domain provides visibility into infrastructure and application health:

- **Metrics collection** (Prometheus scraping)
- **Time-series data** (storage and retention)
- **Alerting** (threshold-based notifications)
- **Dashboards** (Grafana visualization)
- **Performance monitoring** (CPU, memory, I/O, network)
- **Health checks** (container, service, node health)
- **Log metrics** (error rates, event counts)

---

## Key Integrations

Prometheus Agent depends on / integrates with:
- **Docker Agent** (container metrics, Swarm health)
- **Network Agent** (network metrics, throughput)
- **Network Infrastructure Agent** (node health)
- **Samba Agent** (file sharing metrics)
- **WireGuard Agent** (VPN metrics, peer health)
- **Storage & Backup Agent** (backup success metrics)
- **Logging Agent** (log-based metrics)
- **Transmission Protocol Agent** (protocol-specific metrics)

---

## Metrics Collection

### Node-Level Metrics
- CPU usage, load, temperature
- Memory (used, available, swap)
- Disk (usage, I/O, free space)
- Network (bytes in/out, errors, drops)
- System processes

### Container-Level Metrics
- Container CPU & memory
- Network per container
- Disk I/O per container
- Uptime & restart count

### Service-Level Metrics
- Docker Swarm health
- Service replica count
- Task status
- Service availability

### Application-Level Metrics
- Samba share access
- WireGuard peer connections
- Prometheus scrape duration
- Query performance

### Infrastructure Metrics
- Node availability
- Network latency (ping)
- DNS resolution time (Pi-hole)
- VPN tunnel health

---

## Alert Configuration

### Critical (SEV1)
- Node down
- Disk >90% full
- Memory >95% used
- Service replica count mismatch
- Backup failure

### Warning (SEV2)
- High CPU (>80%)
- High memory (>85%)
- Network packet loss >1%
- Service slow (response time)
- Queue buildup

### Information (SEV3)
- Metrics collection lag
- Configuration change
- Routine maintenance
- Non-critical service restart

---

## Quick Links

- [Prometheus Agent Skills](./PROMETHEUS_AGENT_SKILLS.md)
- [Master Index](../../../AGENT_ECOSYSTEM_INDEX.md)
- [Infrastructure Domain](../infrastructure/index.md) (provides metrics)
- [Services Domain](../services/index.md) (provides metrics)
- [Phase 2 - Logging](../../phase-2-observability/index.md) (coordinates with)
- [Phase 3 - Capacity Planning](../../phase-3-operations/index.md) (consumes metrics)
- [Phase 4 - Performance Optimization](../../phase-4-excellence/index.md) (consumes metrics)

---

## Metrics Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                  Prometheus Metrics Collection                │
├──────────────────────────────────────────────────────────────┤
│                                                                │
│  Scrape Targets:                                              │
│  ├─ Node Exporter (24.204.72.65-68) ← Node metrics           │
│  ├─ Docker Daemon ← Container metrics                        │
│  ├─ cAdvisor ← Container resource metrics                    │
│  ├─ Samba Exporter ← File sharing metrics                    │
│  ├─ WireGuard Exporter ← VPN metrics                         │
│  └─ Application metrics (via instrumentation)                │
│                                                                │
│  Time-Series Storage:                                         │
│  └─ Prometheus DB (retention: configurable)                  │
│                                                                │
│  Aggregation & Alerting:                                      │
│  ├─ Alert Rules (threshold-based)                            │
│  ├─ Alert Manager (routing, grouping)                        │
│  └─ Notification Channels (email, Slack, etc.)               │
│                                                                │
│  Visualization:                                               │
│  ├─ Prometheus UI (9090)                                      │
│  ├─ Grafana (if deployed)                                    │
│  └─ Custom dashboards                                        │
│                                                                │
└──────────────────────────────────────────────────────────────┘
```

---

## Data Retention Strategy

| Metric Type | Retention | Purpose |
|-------------|-----------|---------|
| Real-time | 1 hour | On-call alerting |
| Short-term | 1 week | Recent trends |
| Medium-term | 30 days | Monthly analysis |
| Long-term | 1 year | Capacity planning (optional) |

---

## Troubleshooting Observability

**Metrics not appearing**:
1. Check scrape target status in Prometheus UI
2. Verify exporter is running on target host
3. Check firewall rules (Prometheus port 9090)
4. Review Prometheus logs for scrape errors

**High memory usage in Prometheus**:
1. Reduce retention period
2. Disable unused metrics
3. Increase scrape interval
4. Consider external storage (Thanos, etc.)

**Alerts not firing**:
1. Check alert rule syntax
2. Verify Alert Manager is running
3. Test notification channels
4. Review alert rule evaluation logs

---

**Last Updated**: September 16, 2026  
**Status**: Production Operational  
**Next Review**: When adding new scrape targets or changing alert rules
