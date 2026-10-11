# Skills Directory Tombstone

This directory has been **retired** as part of the hard cutover to canonical agent locations.

## Canonical Locations

- Core standards: `../agents/_core/`
- Infrastructure agents: `../agents/operational/infrastructure/`
- Service agents: `../agents/operational/services/`
- Observability agents: `../agents/operational/observability/`
- Quality agents: `../agents/operational/quality/`

## Why This Exists

`skills/` previously contained mirrored copies of operational skill documents. Those mirrors were removed to prevent drift and ensure a single source of truth.

## Migration Note

If you have legacy bookmarks or tooling that referenced `/.agents/skills/*`, update them to the canonical `/.agents/agents/*` paths above.
