## 🔧 Linux SRE Automation Demo
Hands-on Nutanix-aligned SRE samples:

- Health check (Bash): [`health_check.sh`](./linux-sre-automation-demo/scripts/health_check.sh)  
- Log parser (Python): [`log_parser.py`](./linux-sre-automation-demo/scripts/log_parser.py)  
- Patch & verify (Bash): [`patch_update.sh`](./linux-sre-automation-demo/scripts/patch_update.sh)  
- Prometheus config: [`prometheus.yml`](./linux-sre-automation-demo/monitoring/prometheus.yml)  
- Grafana dashboard: [`grafana_dashboard.json`](./linux-sre-automation-demo/monitoring/grafana_dashboard.json)  
- Runbook: [`incident_response.md`](./linux-sre-automation-demo/docs/incident_response.md)

## Quick start
chmod +x scripts/*.sh
./scripts/health_check.sh
python3 scripts/log_parser.py --since "2 hours ago"
sudo ./scripts/patch_update.sh
