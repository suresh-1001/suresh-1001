# OCI API Gateway Demo (Public SSL + Private Backend)

Hands-on example showing how to front a private backend (on VM/LB) with **OCI API Gateway** + **certs** and route requests securely.

## What’s here
- **docs/**
  - `architecture.md` – diagram & flow
  - `setup_steps.md` – step-by-step CLI/Terraform flow
- **infra/terraform/**
  - Minimal Terraform to create API Gateway + Deployment + Usage Plan + API Key (vars required)
- **samples/**
  - `openapi.yaml` – example spec for a `/health` endpoint
- **scripts/**
  - `deploy-cli.sh` – one-shot OCI CLI deploy alternative (if not using Terraform)

## Quick start
- Fill out `infra/terraform/terraform.tfvars` (Compartment OCID, Gateway subnet OCID, etc.)
- `cd infra/terraform && terraform init && terraform apply`
- Or run `scripts/deploy-cli.sh` after setting OCI CLI profile.

