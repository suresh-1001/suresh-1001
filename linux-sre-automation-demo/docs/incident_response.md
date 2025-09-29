# Incident Response (Alert → Resolution)
**Alert intake** → **Triage** (0–5m) → **Stabilize** (5–15m) → **RCA** → **Postmortem**
- Use `scripts/health_check.sh` and `scripts/log_parser.py` in the first 5 minutes.
- Rollback/scale/restart; verify on graphs; document timeline & actions.
