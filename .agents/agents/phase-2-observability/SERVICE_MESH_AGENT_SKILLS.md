# Service Mesh & API Gateway Agent Skills

**Status**: 🟡 TODO - Phase 2, Week 5  
**Priority**: HIGH  
**Documentation Progress**: Placeholder (under development)

## Overview

The Service Mesh Agent manages API gateway deployment, service routing, load balancing, rate limiting, and service-to-service communication. This agent enables scalable microservices architecture with intelligent traffic management and observability.

**Key Responsibilities**:
- API Gateway setup and configuration
- Service routing and load balancing
- Rate limiting and quota management
- Service-to-service authentication (mTLS)
- Request tracing and correlation
- Circuit breaker and resilience patterns
- Blue-green and canary deployments
- Service discovery integration

## Architecture & Context

*To be populated during Phase 2, Week 5 implementation*

- API Gateway platform (Kong, Traefik, NGINX, etc.)
- Service mesh architecture
- Traffic management rules
- mTLS configuration
- Observability integration

## Skill Areas

*Detailed skill documentation to be completed*

### 1. API Gateway Deployment
- Gateway platform selection and deployment
- Configuration management
- Plugin integration
- Performance tuning

### 2. Service Routing & Load Balancing
- Route configuration
- Load balancing algorithms
- Health checks
- Failover handling

### 3. Rate Limiting & Quotas
- Rate limit configuration
- Quota management
- Customer-specific limits
- Burst handling

### 4. Service-to-Service Authentication
- mTLS certificate management
- Service identity verification
- Mutual authentication procedures
- Certificate rotation

### 5. Request Tracing & Correlation
- Distributed tracing setup
- Trace context propagation
- Trace sampling
- Correlation ID management

### 6. Deployment Patterns
- Blue-green deployment coordination
- Canary deployment procedures
- Traffic shifting
- Rollback procedures

## Validation Checklist

*22 validation items to be defined during implementation*

## Integration Points

**Depends On:**
- Network Infrastructure Agent
- Security & Secrets Agent
- Docker Agent
- Prometheus Agent
- Transmission Protocol Agent

**Provides To:**
- Incident Response Agent
- Performance Optimization Agent

## Known Limitations

*To be documented during implementation*

## Reference Implementation

*Examples and real-world deployment patterns to be added*

---

**Phase**: 2 (Observability & Scalability)  
**Timeline**: Week 5  
**Status**: Under Development  
**Last Updated**: October 11, 2026
