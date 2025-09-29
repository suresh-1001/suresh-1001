# Linux SRE Automation Demo

Hands-on examples for a Linux Site Reliability Engineer role:

- **Health Check (Bash)** – CPU/mem/disk/load, service checks.  
- **Log Parser (Python)** – Finds anomalies and top offenders.  
- **Patch/Update (Bash)** – Safe package updates with pre/post checks.  
- **Monitoring** – Prometheus scrape + Grafana dashboard.  
- **Runbook** – docs/incident_response.md

## Quick start
chmod +x scripts/*.sh
./scripts/health_check.sh
python3 scripts/log_parser.py --since "2 hours ago"
sudo ./scripts/patch_update.sh
