# Architecture (High-Level)

Client (Internet) → **OCI API Gateway (443/SSL)** → **Backend** (private service via LB/VCN)
- SSL cert via OCI Certificates or uploaded cert.
- Optional WAF in front of the Gateway.
- Optional Usage Plans + API Keys.
